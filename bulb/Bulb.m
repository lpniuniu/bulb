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

@interface Bulb ()

@property (nonatomic) NSMutableArray<BulbSlot*>* slots;
@property (nonatomic) BulbHistory* history;

@end

@implementation Bulb

+ (instancetype)sharedInstance
{
    static Bulb* core = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        core = [[Bulb alloc] init];
    });
    return core;
}

+ (void)fire:(NSString *)signalIdentifier data:(id)data
{
    Bulb* bulb = [self sharedInstance];
    NSMutableIndexSet* deleteIndexes = [NSMutableIndexSet indexSet];
    NSMutableArray* appendSlots = [NSMutableArray array];
    [bulb.slots enumerateObjectsUsingBlock:^(BulbSlot * _Nonnull slot, NSUInteger idx, BOOL * _Nonnull stop) {
        [slot.fireDataTable setObject:data forKey:signalIdentifier];
        [slot fireStatusWithSignalIdentifier:signalIdentifier status:kBulbSignalStatusOn data:data];
        [self addSignalIdentifierToHistory:[slot hasSignal:signalIdentifier]];
        if (slot.fireCount > 0) {
            [deleteIndexes addIndex:idx];
            if (slot.type == kBulbSignalSlotTypeReAppend) {
                [slot resetSignals];
                [appendSlots addObject:slot];
            }
        }
    }];
    [bulb.slots removeObjectsAtIndexes:deleteIndexes];
    [bulb.slots addObjectsFromArray:appendSlots];
}

+ (void)addSignalIdentifierToHistory:(BulbSignal *)signal
{
    if (signal == nil) {
        return ;
    }
    Bulb* bulb = [self sharedInstance];
    signal.status = kBulbSignalStatusOn;
    [bulb.history.signals addObject:signal];
}

+ (void)regiseterSignal:(NSString *)signalIdentifier block:(BulbBlock)block
{
    Bulb* bulb = [self sharedInstance];
    [bulb.slots addObject:[BulbSolotBuilder buildWithSignalsIdentifier:@[signalIdentifier] block:block type:kBulbSignalSlotTypeInstant]];
}

+ (void)regiseterSignals:(NSArray *)signalIdentifiers block:(BulbBlock)block
{
    Bulb* bulb = [self sharedInstance];
    [bulb.slots addObject:[BulbSolotBuilder buildWithSignalsIdentifier:signalIdentifiers block:block type:kBulbSignalSlotTypeInstant]];
}

+ (void)regiseterSignal:(NSArray *)signalIdentifier foreverblock:(BulbBlock)foreverblock
{
    Bulb* bulb = [self sharedInstance];
    [bulb.slots addObject:[BulbSolotBuilder buildWithSignalsIdentifier:@[signalIdentifier] block:foreverblock type:kBulbSignalSlotTypeReAppend]];
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
    Bulb* bulb = [self sharedInstance];
    __block NSInteger matchCount = 0;
    NSMutableDictionary* dataTable = [NSMutableDictionary dictionary];
    NSMutableSet* signals = [NSMutableSet set];
    [signalIdentifiers enumerateObjectsUsingBlock:^(id  _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
        BulbSignal* signal = [[BulbSignal alloc] initWithSignalIdentifier:identifier];
        [signals addObject:signal];
    }];
    [bulb.history.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
        [signalIdentifiers enumerateObjectsUsingBlock:^(id  _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([identifier isEqualToString:signal.identifier] && signal.status == kBulbSignalStatusOn) {
                [dataTable setObject:signal.data forKey:signal.identifier];
                [signals addObject:signal];
                matchCount++;
            }
        }];
    }];
    if (matchCount == bulb.history.signals.count) {
        if (block) {
            block(dataTable.allValues.firstObject, dataTable);
        }
    } else {
        BulbSlot* slot = [[BulbSlot alloc] init];
        slot.signals = signals;
        slot.block = block;
        slot.type = kBulbSignalSlotTypeInstant;
        [slot.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, BOOL * _Nonnull stop) {
            [slot.fireDataTable setObject:signal.data forKey:signal.identifier];
        }];
        [bulb.slots addObject:slot];
    }
}

@end
