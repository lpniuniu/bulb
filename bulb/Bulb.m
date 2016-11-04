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
@property (nonatomic) dispatch_queue_t saveListDispatchQueue;

@end

static NSString* kGlobalBulbName = @"BulbGlobal";
static NSMutableDictionary* bulbName2bulb = nil;
static dispatch_queue_t bulbName2bulbDispatchQueue = nil;

@implementation Bulb

- (instancetype)init
{
    self = [super init];
    if (self) {
        _saveListDispatchQueue = dispatch_queue_create("saveListDispatchQueue", DISPATCH_QUEUE_SERIAL);
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
    NSMutableArray* deleteSlots = [NSMutableArray array];
    NSMutableArray* appendSlots = [NSMutableArray array];
    [self.slots enumerateObjectsUsingBlock:^(BulbSlot * _Nonnull slot, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([slot hasSignal:[signal.class identifier]]) {
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

- (void)addSignalIdentifierToSaveList:(BulbSignal *)signal
{
    BulbSignal* removeSignal = [self getSignalFromSaveList:[signal.class identifier]];
    // 去重
    dispatch_sync(self.saveListDispatchQueue, ^{
        [self.saveList.signals removeObject:removeSignal];
        [self.saveList.signals addObject:signal];
    });
}

- (void)registerSignal:(BulbSignal *)signal block:(BulbBlock)block
{
    [self registerSignals:@[signal] block:block];
}

- (void)registerSignals:(NSArray<BulbSignal *> *)signals block:(BulbBlock)block
{
    NSMutableDictionary* fireTable = [NSMutableDictionary dictionary];
    [signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fireTable setObject:obj.status forKey:[obj.class identifier]];
    }];
    BulbSlot* slot = [BulbSlotFactory buildWithSignals:signals fireTable:fireTable block:block type:kBulbSignalSlotTypeInstant];
    slot.delegate = self;
    [slot resetSignals];
    [self.slots addObject:slot];
}

- (void)registerSignal:(BulbSignal *)signal foreverblock:(BulbBlock)foreverblock
{
    [self registerSignals:@[signal] foreverblock:foreverblock];
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

- (void)registerSignals:(NSArray<BulbSignal *> *)signals foreverblock:(BulbBlock)foreverblock
{
    if ([self hasSameIdentifierSignal:signals]) {
        return ;
    }
    NSMutableDictionary* fireTable = [NSMutableDictionary dictionary];
    [signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fireTable setObject:obj.status forKey:[obj.class identifier]];
    }];
    BulbSlot* slot = [BulbSlotFactory buildWithSignals:signals fireTable:fireTable block:foreverblock type:kBulbSignalSlotTypeReAppend];
    slot.delegate = self;
    [slot resetSignals];
    [self.slots addObject:slot];
}

- (void)registerSignalIfNotSave:(BulbSignal *)signal block:(BulbBlock)block
{
    [self registerSignalsIfNotSave:@[signal] block:block forever:NO];
}

- (void)registerSignalsIfNotSave:(NSArray<BulbSignal *> *)signals block:(BulbBlock)block
{
    [self registerSignalsIfNotSave:signals block:block forever:NO];
}

- (id)unwrapperData:(id)origindata
{
    id data = nil;
    if (origindata) {
        if ([data isMemberOfClass:[BulbWeakDataWrapper class]]) {
            BulbWeakDataWrapper* weakDataWrapper = (BulbWeakDataWrapper *)origindata;
            if (weakDataWrapper.internalData) {
                data = weakDataWrapper.internalData;
            } else {
                data = [NSNull null];
            }
        } else {
            data = origindata;
        }
    }
    return data;
}

- (void)registerSignalsIfNotSave:(NSArray<BulbSignal *> *)signals block:(BulbBlock)block forever:(BOOL)forever
{
    if ([self hasSameIdentifierSignal:signals]) {
        return ;
    }
    
    __block NSInteger matchCount = 0;
    NSMutableDictionary* dataTable = [NSMutableDictionary dictionary];
    NSMutableArray* matchSignals = [NSMutableArray array];
    __block id firstData = nil;
    __block BOOL firstDataFind = NO;
    dispatch_sync(self.saveListDispatchQueue, ^{
        [self.saveList.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull saveSignal, NSUInteger idx, BOOL * _Nonnull stop) {
            [signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([saveSignal isEqual:signal]) {
                    id unwrapperData = [self unwrapperData:saveSignal.data];
                    if (firstDataFind == NO) {
                        firstDataFind = YES;
                        firstData = unwrapperData;
                    }
                    if (unwrapperData) {
                        [dataTable setObject:unwrapperData forKey:[signal.class identifier]];
                    }
                    [matchSignals addObject:saveSignal];
                    matchCount++;
                }
            }];
        }];
    });
    
    if (matchCount != 0 && matchCount == signals.count) {
        if (block) {
            block(firstData != [NSNull null]? firstData:nil, dataTable);
        }
    } else {
        NSMutableDictionary* fireTable = [NSMutableDictionary dictionary];
        [signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
            [fireTable setObject:signal.status forKey:[signal.class identifier]];
            if (![matchSignals containsObject:signal]) {
                [signal reset];
            }
        }];
        BulbSlot* slot = [BulbSlotFactory buildWithSignals:signals fireTable:fireTable block:block type:forever?kBulbSignalSlotTypeReAppend:kBulbSignalSlotTypeInstant];
        [self.slots addObject:slot];
    }
}

- (void)registerSignalIfNotSave:(BulbSignal *)signal foreverblock:(BulbBlock)block
{
    [self registerSignalsIfNotSave:@[signal] block:block forever:YES];
}

- (void)registerSignalsIfNotSave:(NSArray<BulbSignal *> *)signals foereverblock:(BulbBlock)block
{
    [self registerSignalsIfNotSave:signals block:block forever:YES];
}

- (BulbSignal *)getSignalFromSaveList:(NSString *)signalIdentifier
{
    __block BulbSignal* findSignal = nil;
    dispatch_sync(self.saveListDispatchQueue, ^{
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
    BulbSignal* saveSignal = [self getSignalFromSaveList:[signal.class identifier]];
    if (saveSignal) {
        signal.status = saveSignal.status;
    }
}

@end
