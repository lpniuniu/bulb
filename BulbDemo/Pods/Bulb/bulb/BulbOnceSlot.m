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
    return [super initWithSignals:signals block:^BOOL(id firstData, NSDictionary<NSString *, BulbSignal *> *signalIdentifier2Signal) {
        block(firstData, signalIdentifier2Signal);
        return NO;
    } fireTable:fireTable];
}

@end
