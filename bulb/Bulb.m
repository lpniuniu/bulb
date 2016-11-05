//
//  bulb.m
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "Bulb.h"
#import "BulbSlot.h"
#import "BulbSlotFactory.h"
#import "BulbSaveList.h"
#import "BulbWeakDataWrapper.h"

@interface Bulb () <BulbSlotDelegate>

@property (nonatomic) NSMutableArray<BulbSlot*>* slots;
@property (nonatomic) BulbSaveList* saveList;
@property (nonatomic) dispatch_queue_t bulbDispatchQueue;
@property (nonatomic) dispatch_semaphore_t bulbSemaphore;

@end

static NSString* kGlobalBulbName = @"BulbGlobal";
static NSMutableDictionary* bulbName2bulb = nil;
static dispatch_queue_t bulbName2bulbDispatchQueue = nil;

@implementation Bulb

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bulbDispatchQueue = dispatch_queue_create("bulbDispatchQueue", DISPATCH_QUEUE_SERIAL);
        _bulbSemaphore = dispatch_semaphore_create(1);
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            bulbName2bulbDispatchQueue = dispatch_queue_create("bulbName2bulbDispatchQueue", DISPATCH_QUEUE_SERIAL);
        });
    }
    return self;
}

+ (instancetype)bulbGlobal
{
    static Bulb* bulb = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bulb = [[Bulb alloc] init];
        bulb.slots = [NSMutableArray array];
        bulb.saveList = [[BulbSaveList alloc] init];
        bulb.name = kGlobalBulbName;
    });
    return bulb;
}

+ (instancetype)bulbWithName:(NSString *)name
{
    __block Bulb* bulb = nil;
    dispatch_sync(bulbName2bulbDispatchQueue, ^{
        bulb = [bulbName2bulb objectForKey:name];
    });
    if (!bulb) {
        bulb = [[Bulb alloc] init];
        bulb.slots = [NSMutableArray array];
        bulb.saveList = [[BulbSaveList alloc] init];
        bulb.name = name;
        dispatch_sync(bulbName2bulbDispatchQueue, ^{
            if (bulbName2bulb == nil) {
                bulbName2bulb = [NSMutableDictionary dictionary];
            }
            [bulbName2bulb setObject:bulb forKey:name];
        });
    }
    return bulb;
}

- (void)fire:(BulbSignal *)signal data:(id)data
{
    [self fire:signal data:data toSlots:self.slots];
}

- (void)fire:(BulbSignal *)signal data:(id)data toSlots:(NSArray<BulbSlot *> *)slots
{
    NSMutableArray* deleteSlots = [NSMutableArray array];
    NSMutableArray* appendSlots = [NSMutableArray array];
    
    dispatch_semaphore_wait(self.bulbSemaphore, DISPATCH_TIME_FOREVER);
    
    [slots enumerateObjectsUsingBlock:^(BulbSlot * _Nonnull slot, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([slot hasSignal:[signal identifier]]) {
            [slot fireSignal:signal data:data];
            if (slot.fireCount > 0) {
                [deleteSlots addObject:slot];
                if (slot.type == kBulbSignalSlotTypeReAppend) {
                    [slot resetSignals];
                    [appendSlots addObject:slot];
                }
            }
        }
    }];
    [self.slots removeObjectsInArray:deleteSlots];
    [self.slots addObjectsFromArray:appendSlots];
    
    dispatch_semaphore_signal(self.bulbSemaphore);
}

- (void)fireAndSave:(BulbSignal *)signal data:(id)data
{
    [self save:signal data:data];
    [self fire:signal data:data];
}

- (void)save:(BulbSignal *)signal data:(id)data
{
    signal.data = data;
    [self addSignalIdentifierToSaveList:signal];
}

- (void)remove:(BulbSignal *)signal
{
    dispatch_sync(self.bulbDispatchQueue, ^{
        [self.saveList.signals removeObject:signal];
    });
}

- (void)addSignalIdentifierToSaveList:(BulbSignal *)signal
{
    BulbSignal* removeSignal = [self getSignalFromSaveList:[signal.class identifier]];
    // 去重
    dispatch_sync(self.bulbDispatchQueue, ^{
        [self.saveList.signals removeObject:removeSignal];
        [self.saveList.signals addObject:signal];
    });
}

- (BulbSlot *)registerSignal:(BulbSignal *)signal block:(BulbBlock)block
{
    return [self registerSignals:@[signal] block:block];
}

- (BulbSlot *)registerSignals:(NSArray<BulbSignal *> *)signals block:(BulbBlock)block
{
    return [self registerSignals:signals block:block forever:NO];
}

- (BulbSlot *)registerSignal:(BulbSignal *)signal foreverblock:(BulbBlock)foreverblock
{
    return [self registerSignals:@[signal] block:foreverblock forever:YES];
}

- (BulbSlot *)registerSignals:(NSArray<BulbSignal *> *)signals foreverblock:(BulbBlock)foreverblock
{
    return [self registerSignals:signals block:foreverblock forever:YES];
}

- (BulbSlot *)registerSignals:(NSArray<BulbSignal *> *)signals block:(BulbBlock)block forever:(BOOL)forever
{
    if ([self hasSameIdentifierSignal:signals]) {
        return nil;
    }
    NSMutableDictionary* fireTable = [NSMutableDictionary dictionary];
    [signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fireTable setObject:obj.status forKey:[obj identifier]];
    }];
    BulbSlot* slot = [BulbSlotFactory buildWithSignals:signals fireTable:fireTable block:block type:forever?kBulbSignalSlotTypeReAppend:kBulbSignalSlotTypeInstant];
    slot.delegate = self;
    [slot resetSignals];
    
    dispatch_semaphore_wait(self.bulbSemaphore, DISPATCH_TIME_FOREVER);
    
    [self.slots addObject:slot];
    
    dispatch_semaphore_signal(self.bulbSemaphore);
    
    if ([slot canBeFire]) {
        BulbSignal* signal = slot.signals.firstObject;
        if (signal) {
            [self fire:signal data:signal.data toSlots:@[slot]];
        }
    }
    return slot;
}

- (BOOL)hasSameIdentifierSignal:(NSArray<BulbSignal *> *)signals
{
    __block BOOL result = NO;
    NSMutableArray* identifiers = [NSMutableArray array];
    [signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([identifiers containsObject:[signal identifier]]) {
            NSLog(@"you can not register same identifier signals, register is no effective");
            NSAssert(NO, @"you can not register same identifier signals, register is no effective");
            result = YES;
            *stop = YES;
        }
        [identifiers addObject:signal.identifier];
    }];
    return result;
}

- (BulbSignal *)getSignalFromSaveList:(NSString *)signalIdentifier
{
    __block BulbSignal* findSignal = nil;
    dispatch_sync(self.bulbDispatchQueue, ^{
        [self.saveList.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[signal.class identifier] isEqualToString:signalIdentifier]) {
                findSignal = signal;
                *stop = YES;
            }
        }];
    });
    return findSignal;
}

#pragma bulb slot delegate
- (void)bulbSlotInternalSignalRest:(BulbSignal *)signal
{
    if (signal.initialStatusFromSave == NO) {
        return ;
    }
    BulbSignal* saveSignal = [self getSignalFromSaveList:[signal.class identifier]];
    if (saveSignal) {
        signal.status = saveSignal.status;
        signal.data = saveSignal.data;
    }
}

@end
