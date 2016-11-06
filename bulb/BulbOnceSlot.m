//
//  BulbOnceSlot.m
//  bulb
//
//  Created by FanFamily on 2016/11/6.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbOnceSlot.h"

@implementation BulbOnceSlot

- (instancetype)initWithSignals:(NSArray<BulbSignal *> *)signals block:(BulbBlock)block fireTable:(NSArray<NSDictionary<NSString *, NSString *>*>* )fireTable
{
    return [super initWithSignals:signals block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        block(firstData, signalIdentifier2data);
        return NO;
    } fireTable:fireTable];
}

@end
