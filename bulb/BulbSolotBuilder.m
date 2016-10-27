//
//  BulbRegister.m
//  bulb
//
//  Created by FanFamily on 16/8/12.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbSolotBuilder.h"
#import "BulbConstant.h"
#import "NSArray+BBDistinct.h"

@implementation BulbSolotBuilder

+ (BulbSlot *)buildWithSignalsIdentifier:(NSArray *)signalIdentifiers block:(BulbBlock)block type:(BulbSignalSlotType)type
{
    NSMutableArray* signals = [NSMutableArray array];
    NSMutableDictionary* table = [NSMutableDictionary dictionary];
    // Distinct
    [[signalIdentifiers bb_distinct] enumerateObjectsUsingBlock:^(id  _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
        BulbSignal* signal = [[BulbSignal alloc] initWithSignalIdentifier:identifier];
        [signals addObject:signal];
        [table setObject:kBulbSignalStatusOn forKey:identifier];
    }];
    return [[BulbSlot alloc] initWithSignals:signals block:block fireTable:@[table] type:type];
}

+ (BulbSlot *)buildWithSignalsIdentifierMap:(NSDictionary *)signalIdentifier2status block:(BulbBlock)block type:(BulbSignalSlotType)type
{
    NSMutableArray* signals = [NSMutableArray array];
    [signalIdentifier2status.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
        BulbSignal* signal = [[BulbSignal alloc] initWithSignalIdentifier:identifier];
        [signals addObject:signal];
    }];
    return [[BulbSlot alloc] initWithSignals:signals block:block fireTable:@[signalIdentifier2status] type:type];
}

@end
