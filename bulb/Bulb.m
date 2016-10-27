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
#import "BulbHistory.h"
#import "BulbWeakDataWrapper.h"

@interface Bulb ()

@property (nonatomic) NSMutableArray<BulbSlot*>* slots;
@property (nonatomic) BulbHistory* history;

@end

@implementation Bulb

+ (instancetype)sharedInstance
{
    static Bulb* bulb = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bulb = [[Bulb alloc] init];
        bulb.slots = [NSMutableArray array];
        bulb.history = [[BulbHistory alloc] init];
    });
    return bulb;
}

+ (void)fire:(NSString *)signalIdentifier data:(id)data
{
    [self fire:signalIdentifier status:kBulbSignalStatusOn data:data save:NO];
}

+ (void)fire:(NSString *)signalIdentifier status:(NSString *)status data:(id)data
{
    [self fire:signalIdentifier status:status data:data save:NO];
}

+ (void)fireAndSave:(NSString *)signalIdentifier data:(id)data
{
    [self fire:signalIdentifier status:kBulbSignalStatusOn data:data save:YES];
}

+ (void)fireAndSave:(NSString *)signalIdentifier status:(NSString *)status data:(id)data
{
    [self fire:signalIdentifier status:status data:data save:YES];
}

+ (void)fire:(NSString *)signalIdentifier status:(NSString *)status data:(id)data save:(BOOL)save
{
    Bulb* bulb = [self sharedInstance];
    if (save) {
        [self save:signalIdentifier status:status data:data];
    }
    NSMutableArray* deleteSlots = [NSMutableArray array];
    NSMutableArray* appendSlots = [NSMutableArray array];
    [bulb.slots enumerateObjectsUsingBlock:^(BulbSlot * _Nonnull slot, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [bulb.slots removeObjectsInArray:deleteSlots];
    [bulb.slots addObjectsFromArray:appendSlots];
}

+ (void)save:(NSString *)signalIdentifier status:(NSString *)status data:(id)data
{
    BulbSignal* signal = [[BulbSignal alloc] initWithSignalIdentifier:signalIdentifier];
    signal.status = status;
    signal.data = data;
    [self addSignalIdentifierToHistory:signal];
}

+ (void)addSignalIdentifierToHistory:(BulbSignal *)signal
{
    BulbSignal* removeSignal = [self getSignalFromHistory:signal.identifier];
    Bulb* bulb = [self sharedInstance];
    // 去重
    [bulb.history.signals removeObject:removeSignal];
    if (signal.status == nil) {
        signal.status = kBulbSignalStatusOn;
    }
    [bulb.history.signals addObject:signal];
}

+ (void)regiseterSignal:(NSString *)signalIdentifier block:(BulbBlock)block
{
    Bulb* bulb = [self sharedInstance];
    [bulb.slots addObject:[BulbSolotBuilder buildWithSignalsIdentifier:@[signalIdentifier] block:block type:kBulbSignalSlotTypeInstant]];
}

+ (void)regiseterSignal:(NSString *)signalIdentifier status:(NSString *)status block:(BulbBlock)block
{
    Bulb* bulb = [self sharedInstance];
    [bulb.slots addObject:[BulbSolotBuilder buildWithSignalsIdentifierMap:@{signalIdentifier:status} block:block type:kBulbSignalSlotTypeInstant]];
}

+ (void)regiseterSignals:(NSArray *)signalIdentifiers block:(BulbBlock)block
{
    Bulb* bulb = [self sharedInstance];
    [bulb.slots addObject:[BulbSolotBuilder buildWithSignalsIdentifier:signalIdentifiers block:block type:kBulbSignalSlotTypeInstant]];
}

+ (void)regiseterSignal:(NSString *)signalIdentifier foreverblock:(BulbBlock)foreverblock
{
    Bulb* bulb = [self sharedInstance];
    [bulb.slots addObject:[BulbSolotBuilder buildWithSignalsIdentifier:@[signalIdentifier] block:foreverblock type:kBulbSignalSlotTypeReAppend]];
}

+ (void)regiseterSignal:(NSString *)signalIdentifier status:(NSString *)status foreverblock:(BulbBlock)foreverblock
{
    Bulb* bulb = [self sharedInstance];
    [bulb.slots addObject:[BulbSolotBuilder buildWithSignalsIdentifierMap:@{signalIdentifier:status} block:foreverblock type:kBulbSignalSlotTypeReAppend]];
}

+ (void)regiseterSignals:(NSArray *)signalIdentifiers foreverblock:(BulbBlock)foreverblock
{
    Bulb* bulb = [self sharedInstance];
    [bulb.slots addObject:[BulbSolotBuilder buildWithSignalsIdentifier:signalIdentifiers block:foreverblock type:kBulbSignalSlotTypeReAppend]];
}

+ (void)runAfterSignal:(NSString *)signalIdentifier block:(BulbBlock)block
{
    [self runAfterSignals:@[signalIdentifier] block:block];
}

+ (void)runAfterSignals:(NSArray *)signalIdentifiers block:(BulbBlock)block
{
    NSMutableDictionary* signalIdentifier2status = [NSMutableDictionary dictionary];
    [signalIdentifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
        [signalIdentifier2status setObject:kBulbSignalStatusOn forKey:identifier];
    }];
    [self runAfterSignalsWithStatus:signalIdentifier2status block:block];
}

+ (void)runAfterSignal:(NSString *)signalIdentifier status:(NSString *)status block:(BulbBlock)block
{
    NSMutableDictionary* signalIdentifier2status = [NSMutableDictionary dictionary];
    [signalIdentifier2status setObject:status forKey:signalIdentifier];
    [self runAfterSignalsWithStatus:signalIdentifier2status block:block];
}

+ (void)runAfterSignalsWithStatus:(NSDictionary *)signalIdentifier2status block:(BulbBlock)block
{
    Bulb* bulb = [self sharedInstance];
    __block NSInteger matchCount = 0;
    NSMutableDictionary* dataTable = [NSMutableDictionary dictionary];
    NSMutableArray* signals = [NSMutableArray array];
    [signalIdentifier2status.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
        BulbSignal* signal = [[BulbSignal alloc] initWithSignalIdentifier:identifier];
        [signals addObject:signal];
    }];
    [bulb.history.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
        [signalIdentifier2status.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([identifier isEqualToString:signal.identifier] && [signalIdentifier2status objectForKey:identifier] == signal.status) {
                if (signal.data) {
                    [dataTable setObject:signal.data forKey:signal.identifier];
                }
                [signals addObject:signal];
                matchCount++;
            }
        }];
    }];
    if (matchCount != 0 && matchCount == signalIdentifier2status.allKeys.count) {
        if (block) {
            block(dataTable.allValues.firstObject, dataTable);
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
        [bulb.slots addObject:slot];
    }
}

+ (void)runNoSignal:(NSString *)signalIdentifier block:(void(^)())block
{
    [self runNoSignals:@[signalIdentifier] block:block];
}

+ (void)runNoSignals:(NSArray *)signalIdentifiers block:(void(^)())block
{
    Bulb* bulb = [self sharedInstance];
    __block NSInteger matchCount = 0;
    [bulb.history.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
        [signalIdentifiers enumerateObjectsUsingBlock:^(id  _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([identifier isEqualToString:signal.identifier] && signal.status == kBulbSignalStatusOn) {
                matchCount++;
            }
        }];
    }];
    if (matchCount == 0 || matchCount != bulb.history.signals.count) {
        if (block) {
            block();
        }
    }
}

+ (BulbSignal *)getSignalFromHistory:(NSString *)signalIdentifier
{
    Bulb* bulb = [self sharedInstance];
    __block BulbSignal* findSignal = nil;
    [bulb.history.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([signal.identifier isEqualToString:signalIdentifier]) {
            findSignal = signal;
            *stop = YES;
        }
    }];
    return findSignal;
}

+ (NSString *)getSignalStatusFromHistory:(NSString *)signalIdentifier
{
    Bulb* bulb = [self sharedInstance];
    __block NSString* findStatus = nil;
    [bulb.history.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([signal.identifier isEqualToString:signalIdentifier]) {
            findStatus = signal.status;
            *stop = YES;
        }
    }];
    return findStatus;
}

@end
