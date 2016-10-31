//
//  bulb.m
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "Bulb.h"
#import "BulbSlot.h"
#import "BulbSolotBuilder.h"
#import "BulbSaveList.h"
#import "BulbWeakDataWrapper.h"

@interface Bulb () <BulbSlotDelegate>

@property (nonatomic) NSMutableArray<BulbSlot*>* slots;
@property (nonatomic) BulbSaveList* saveList;
@property (nonatomic) dispatch_queue_t saveListDispatchQueue;

@end

static NSString* kGlobalBulbName = @"BulbGlobal";
static NSMutableDictionary* bulbName2bulb = nil;

@implementation Bulb

- (instancetype)init
{
    self = [super init];
    if (self) {
        _saveListDispatchQueue = dispatch_queue_create("saveListDispatchQueue", DISPATCH_QUEUE_SERIAL);
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
    Bulb* bulb = [bulbName2bulb objectForKey:name];
    if (!bulb) {
        bulb = [[Bulb alloc] init];
        bulb.slots = [NSMutableArray array];
        bulb.saveList = [[BulbSaveList alloc] init];
        bulb.name = name;
        if (bulbName2bulb == nil) {
            bulbName2bulb = [NSMutableDictionary dictionary];
        }
        [bulbName2bulb setObject:bulb forKey:name];
    }
    return bulb;
}

- (void)fire:(NSString *)signalIdentifier data:(id)data
{
    [self fire:signalIdentifier status:kBulbSignalStatusOn data:data save:NO];
}

- (void)fire:(NSString *)signalIdentifier status:(NSString *)status data:(id)data
{
    [self fire:signalIdentifier status:status data:data save:NO];
}

- (void)fireAndSave:(NSString *)signalIdentifier data:(id)data
{
    [self fire:signalIdentifier status:kBulbSignalStatusOn data:data save:YES];
}

- (void)fireAndSave:(NSString *)signalIdentifier status:(NSString *)status data:(id)data
{
    [self fire:signalIdentifier status:status data:data save:YES];
}

- (void)fire:(NSString *)signalIdentifier status:(NSString *)status data:(id)data save:(BOOL)save
{
    if (save) {
        [self save:signalIdentifier status:status data:data];
    }
    NSMutableArray* deleteSlots = [NSMutableArray array];
    NSMutableArray* appendSlots = [NSMutableArray array];
    [self.slots enumerateObjectsUsingBlock:^(BulbSlot * _Nonnull slot, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([slot hasSignal:signalIdentifier]) {
            [slot fireStatusWithSignalIdentifier:signalIdentifier status:status data:data];
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

- (void)save:(NSString *)signalIdentifier data:(id)data
{
    [self save:signalIdentifier status:kBulbSignalStatusOn data:data];
}

- (void)save:(NSString *)signalIdentifier status:(NSString *)status data:(id)data
{
    BulbSignal* signal = [[BulbSignal alloc] initWithSignalIdentifier:signalIdentifier];
    signal.status = status;
    signal.data = data;
    [self addSignalIdentifierTosaveList:signal];
}

- (void)addSignalIdentifierTosaveList:(BulbSignal *)signal
{
    BulbSignal* removeSignal = [self getSignalFromSaveList:signal.identifier];
    // 去重
    dispatch_sync(self.saveListDispatchQueue, ^{
        [self.saveList.signals removeObject:removeSignal];
        [self.saveList.signals addObject:signal];
    });
    if (signal.status == nil) {
        signal.status = kBulbSignalStatusOn;
    }
}

- (void)registerSignal:(NSString *)signalIdentifier block:(BulbBlock)block
{
    BulbSlot* slot = [BulbSolotBuilder buildWithSignalsIdentifier:@[signalIdentifier] block:block type:kBulbSignalSlotTypeInstant];
    slot.delegate = self;
    [self.slots addObject:slot];
}

- (void)registerSignal:(NSString *)signalIdentifier status:(NSString *)status block:(BulbBlock)block
{
    BulbSlot* slot = [BulbSolotBuilder buildWithSignalsIdentifierMap:@{signalIdentifier:status} block:block type:kBulbSignalSlotTypeInstant];
    slot.delegate = self;
    [self.slots addObject:slot];
}

- (void)registerSignals:(NSArray *)signalIdentifiers block:(BulbBlock)block
{
    BulbSlot* slot = [BulbSolotBuilder buildWithSignalsIdentifier:signalIdentifiers block:block type:kBulbSignalSlotTypeInstant];
    slot.delegate = self;
    [self.slots addObject:slot];
}

- (void)registerSignal:(NSString *)signalIdentifier foreverblock:(BulbBlock)foreverblock
{
    BulbSlot* slot = [BulbSolotBuilder buildWithSignalsIdentifier:@[signalIdentifier] block:foreverblock type:kBulbSignalSlotTypeReAppend];
    slot.delegate = self;
    [self.slots addObject:[BulbSolotBuilder buildWithSignalsIdentifier:@[signalIdentifier] block:foreverblock type:kBulbSignalSlotTypeReAppend]];
}

- (void)registerSignal:(NSString *)signalIdentifier status:(NSString *)status foreverblock:(BulbBlock)foreverblock
{
    BulbSlot* slot = [BulbSolotBuilder buildWithSignalsIdentifierMap:@{signalIdentifier:status} block:foreverblock type:kBulbSignalSlotTypeReAppend];
    slot.delegate = self;
    [self.slots addObject:slot];
}

- (void)registerSignals:(NSArray *)signalIdentifiers foreverblock:(BulbBlock)foreverblock
{
    BulbSlot* slot = [BulbSolotBuilder buildWithSignalsIdentifier:signalIdentifiers block:foreverblock type:kBulbSignalSlotTypeReAppend];
    slot.delegate = self;
    [self.slots addObject:slot];
}

- (void)registerSignalIfNotSave:(NSString *)signalIdentifier block:(BulbBlock)block
{
    [self registerSignalsIfNotSave:@[signalIdentifier] block:block];
}

- (void)registerSignalsIfNotSave:(NSArray *)signalIdentifiers block:(BulbBlock)block
{
    NSMutableDictionary* signalIdentifier2status = [NSMutableDictionary dictionary];
    [signalIdentifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
        [signalIdentifier2status setObject:kBulbSignalStatusOn forKey:identifier];
    }];
    [self registerSignalsIfNotSaveWithStatus:signalIdentifier2status block:block];
}

- (void)registerSignalIfNotSave:(NSString *)signalIdentifier status:(NSString *)status block:(BulbBlock)block
{
    NSMutableDictionary* signalIdentifier2status = [NSMutableDictionary dictionary];
    [signalIdentifier2status setObject:status forKey:signalIdentifier];
    [self registerSignalsIfNotSaveWithStatus:signalIdentifier2status block:block];
}

- (void)registerSignalsIfNotSaveWithStatus:(NSDictionary *)signalIdentifier2status block:(BulbBlock)block
{
    __block NSInteger matchCount = 0;
    NSMutableDictionary* dataTable = [NSMutableDictionary dictionary];
    NSMutableArray* signals = [NSMutableArray array];
    [signalIdentifier2status.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
        BulbSignal* signal = [[BulbSignal alloc] initWithSignalIdentifier:identifier];
        [signals addObject:signal];
    }];
    __block id firstData = nil;
    dispatch_sync(self.saveListDispatchQueue, ^{
        [self.saveList.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
            [signalIdentifier2status.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([identifier isEqualToString:signal.identifier] && [signalIdentifier2status objectForKey:identifier] == signal.status) {
                    if (firstData == nil) {
                        if (signal.data) {
                            if ([signal.data isMemberOfClass:[BulbWeakDataWrapper class]]) {
                                BulbWeakDataWrapper* weakDataWrapper = (BulbWeakDataWrapper *)signal.data;
                                if (weakDataWrapper.internalData) {
                                    firstData = weakDataWrapper.internalData;
                                } else {
                                    firstData = [NSNull null];
                                }
                            } else {
                                firstData = signal.data;
                            }
                        } else {
                            firstData = [NSNull null];
                        }
                    }
                    if ([signal.data isMemberOfClass:[BulbWeakDataWrapper class]]) {
                        BulbWeakDataWrapper* weakDataWrapper = (BulbWeakDataWrapper *)signal.data;
                        if (weakDataWrapper.internalData) {
                            [dataTable setObject:weakDataWrapper.internalData forKey:signal.identifier];
                        }
                    } else if (signal.data) {
                        [dataTable setObject:signal.data forKey:signal.identifier];
                    }
                    [signals addObject:signal];
                    matchCount++;
                }
            }];
        }];
    });
    
    if (matchCount != 0 && matchCount == signalIdentifier2status.allKeys.count) {
        if (block) {
            block(firstData != [NSNull null]? firstData:nil, dataTable);
        }
    } else {
        BulbSlot* slot = [[BulbSlot alloc] init];
        slot.signals = signals;
        slot.block = block;
        slot.type = kBulbSignalSlotTypeInstant;
        NSMutableDictionary* fireTableDict = [NSMutableDictionary dictionary];
        [slot.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
            [fireTableDict setObject:[signalIdentifier2status objectForKey:signal.identifier] forKey:signal.identifier];
        }];
        slot.fireTable = @[fireTableDict];
        [self.slots addObject:slot];
    }
}

- (BulbSignal *)getSignalFromSaveList:(NSString *)signalIdentifier
{
    __block BulbSignal* findSignal = nil;
    dispatch_sync(self.saveListDispatchQueue, ^{
        [self.saveList.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([signal.identifier isEqualToString:signalIdentifier]) {
                findSignal = signal;
                *stop = YES;
            }
        }];
    });
    return findSignal;
}

- (NSString *)getSignalStatusFromSaveList:(NSString *)signalIdentifier
{
    __block NSString* findStatus = nil;
    dispatch_sync(self.saveListDispatchQueue, ^{
        [self.saveList.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([signal.identifier isEqualToString:signalIdentifier]) {
                findStatus = signal.status;
                *stop = YES;
            }
        }];
    });
    return findStatus;
}

#pragma bulb slot delegate
- (void)bulbSlotInternalSignalRest:(BulbSignal *)signal
{
    NSString* status = [self getSignalStatusFromSaveList:signal.identifier];
    if (status) {
        signal.status = status;
    }
}

@end
