//
//  bulb.m
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "Bulb.h"
#import "BulbSlotFactory.h"
#import "BulbHungUpList.h"
#import "BulbWeakDataWrapper.h"
#import "BulbRecorder+Private.h"

@interface Bulb ()

@property (nonatomic) NSMutableArray<BulbSlot*>* slots;
@property (nonatomic) BulbHungUpList* hungUpList;
@property (nonatomic) dispatch_queue_t bulbDispatchQueue;

@end

static NSString* kGlobalBulbName = @"BulbGlobal";
static NSMapTable* bulbName2bulb = nil;
static dispatch_queue_t bulbName2bulbDispatchQueue = nil;

@implementation Bulb

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bulbDispatchQueue = dispatch_queue_create("bulbDispatchQueue", DISPATCH_QUEUE_SERIAL);
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
        bulb.hungUpList = [[BulbHungUpList alloc] init];
        bulb.name = kGlobalBulbName;
    });
    return bulb;
}

+ (instancetype)bulbWithName:(NSString *)name
{
    __block Bulb* bulb = nil;
    if (bulbName2bulbDispatchQueue) {
        dispatch_sync(bulbName2bulbDispatchQueue, ^{
            bulb = [bulbName2bulb objectForKey:name];
        });
    }
    
    if (!bulb) {
        bulb = [[Bulb alloc] init];
        bulb.slots = [NSMutableArray array];
        bulb.hungUpList = [[BulbHungUpList alloc] init];
        bulb.name = name;
        dispatch_sync(bulbName2bulbDispatchQueue, ^{
            if (bulbName2bulb == nil) {
                bulbName2bulb = [NSMapTable strongToWeakObjectsMapTable];
            }
            [bulbName2bulb setObject:bulb forKey:name];
        });
    }
    return bulb;
}

- (void)fire:(BulbSignal *)signal data:(id)data
{
    [self fire:signal data:data toSlots:[self.slots copy]];
}

- (void)handleFromHungUpList:(BulbSlot *)slot
{
    [slot.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
        if (signal.hungUpBehavior == kHungUpTypeRecover) {
            BulbSignal* hungUpSignal = [self getSignalFromHungUpList:[signal identifier]];
            if (hungUpSignal) {
                signal.status = hungUpSignal.status;
                signal.data = hungUpSignal.data;
            }
        } else if (signal.hungUpBehavior == kHungUpTypePickOff) {
            BulbSignal* hungUpSignal = [self getSignalFromHungUpList:[signal identifier]];
            if (hungUpSignal) {
                signal.status = hungUpSignal.status;
                signal.data = hungUpSignal.data;
            }
            [self pickOff:hungUpSignal];
        }
    }];
}

- (void)fire:(BulbSignal *)signal data:(id)data toSlots:(NSArray<BulbSlot *> *)slots
{
    [[BulbRecorder sharedInstance] addSignalFireRecord:self signal:signal];
    
    // 刷新hungUpList
    if ([self getSignalFromHungUpList:signal.identifier]) {
        [self hungUp:signal data:data];
    }
    
    NSMutableArray* deleteSlots = [NSMutableArray array];
    NSMutableArray* appendSlots = [NSMutableArray array];
    
    [slots enumerateObjectsUsingBlock:^(BulbSlot * _Nonnull slot, NSUInteger idx, BOOL * _Nonnull stop) {
        [self handleFromHungUpList:slot];
        signal.data = data;
        if ([slot hasSignal:signal] && ![slot isFiltered:signal]) {
            BulbSignalSlotFireType fireType = [slot fireSignal:signal data:data];
            if (slot.fireCount > 0) {
                [deleteSlots addObject:slot];
                // 如果返回true，代表循环添加
                if (fireType == kBulbSignalSlotFiredResultYes) {
                    [slot resetForeverSignals];
                    [self handleFromHungUpList:slot];
                    [appendSlots addObject:slot];
                }
            }
        }
    }];
    
    dispatch_sync(self.bulbDispatchQueue, ^{
        [self.slots removeObjectsInArray:deleteSlots];
        [self.slots addObjectsFromArray:appendSlots];
    });
}

- (void)hungUpAndFire:(BulbSignal *)signal data:(id)data
{
    [self hungUp:signal data:data];
    [self fire:signal data:data];
}

- (void)hungUp:(BulbSignal *)signal data:(id)data
{
    signal.data = data;
    [self addSignalIdentifierToHungUpList:signal];
}

- (void)pickOff:(BulbSignal *)signal
{
    dispatch_sync(self.bulbDispatchQueue, ^{
        [self.hungUpList.signals removeObject:signal];
    });
    
    // 当观察灯移掉后，将观察信号重置状态
    [self.slots enumerateObjectsUsingBlock:^(BulbSlot * _Nonnull slot, NSUInteger idx, BOOL * _Nonnull stop) {
        [slot.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull internalSignal, NSUInteger idx, BOOL * _Nonnull stop) {
            if (internalSignal.hungUpBehavior == kHungUpTypeRecover
                && [signal.identifier isEqualToString:internalSignal.identifier]) {
                [internalSignal reset];
            }
        }];
    }];
}

- (void)addSignalIdentifierToHungUpList:(BulbSignal *)signal
{
    BulbSignal* removeSignal = [self getSignalFromHungUpList:[signal identifier]];
    // 去重
    dispatch_sync(self.bulbDispatchQueue, ^{
        [self.hungUpList.signals removeObject:removeSignal];
        [self.hungUpList.signals addObject:signal];
    });
}

- (BulbSlot *)registerSignal:(BulbSignal *)signal block:(BulbHasResultBlock)block
{
    return [self registerSignals:@[signal] block:block];
}

- (BulbSlot *)registerSignals:(NSArray<BulbSignal *> *)signals block:(BulbHasResultBlock)block
{
    return [self registerSignals:signals block:block filterBlock:nil];
}

- (BulbSlot *)registerSignal:(BulbSignal *)signal block:(BulbHasResultBlock)block filterBlock:(BulbFilterBlock)filterBlock
{
    return [self registerSignals:@[signal] block:block filterBlock:filterBlock];
}

- (BulbSlot *)registerSignals:(NSArray<BulbSignal *> *)signals block:(BulbHasResultBlock)block filterBlock:(BulbFilterBlock)filterBlock
{
    [[BulbRecorder sharedInstance] addSignalsRegisterRecord:self signals:signals];
    
    if ([self hasSameIdentifierSignal:signals]) {
        return nil;
    }
    NSMutableDictionary* fireTable = [NSMutableDictionary dictionary];
    [signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fireTable setObject:@(obj.status) forKey:[obj identifier]];
    }];
    
    BulbSlot* slot = [BulbSlotFactory buildWithSignals:signals fireTable:fireTable block:block filterBlock:filterBlock];
    [slot resetSignals];
    [self handleFromHungUpList:slot];
    
    dispatch_sync(self.bulbDispatchQueue, ^{
        [self.slots addObject:slot];
    });
    
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

- (BulbSignal *)getSignalFromHungUpList:(NSString *)signalIdentifier
{
    __block BulbSignal* findSignal = nil;
    dispatch_sync(self.bulbDispatchQueue, ^{
        [self.hungUpList.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[signal identifier] isEqualToString:signalIdentifier]) {
                findSignal = signal;
                *stop = YES;
            }
        }];
    });
    return findSignal;
}

- (NSString *)hungUpListDescription
{
    return self.hungUpList.description;
}

- (void)unRegister:(BulbSlot *)slot
{
    dispatch_sync(self.bulbDispatchQueue, ^{
        [self.slots removeObject:slot];
    });
}

@end
