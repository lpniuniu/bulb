//
//  BulbRegister.m
//  bulb
//
//  Created by FanFamily on 16/8/12.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbSolotBuilder.h"
#import "BulbConstant.h"

@implementation BulbSolotBuilder

+ (BulbSlot *)buildWithSignalsIdentifier:(NSArray *)signalIdentifiers block:(BulbBlock)block type:(BulbSignalSlotType)type
{
    
    NSSet* signals = [NSSet set];
    NSMutableDictionary* table = [NSMutableDictionary dictionary];
    [signalIdentifiers enumerateObjectsUsingBlock:^(id  _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
        BulbSignal* signal = [[BulbSignal alloc] initWithSignalIdentifier:identifier];
        [signals setByAddingObject:signal];
        [table setObject:kBulbSignalStatusOn forKey:identifier];
    }];
    
    return [[BulbSlot alloc] initWithSignals:signals block:block fireTable:@[table] type:type];
}

+ (BulbSlot *)buildWithSignalsIdentifierMap:(NSDictionary *)signalIdentifier2status block:(BulbBlock)block type:(BulbSignalSlotType)type
{
    NSSet* signals = [NSSet set];
    [signalIdentifier2status.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
        BulbSignal* signal = [[BulbSignal alloc] initWithSignalIdentifier:identifier];
        [signals setByAddingObject:signal];
    }];
    return [[BulbSlot alloc] initWithSignals:signals block:block fireTable:@[signalIdentifier2status] type:type];
}

@end
