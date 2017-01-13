//
//  BulbRegister.m
//  bulb
//
//  Created by FanFamily on 16/8/12.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbSlotFactory.h"
#import "BulbConstant.h"

@implementation BulbSlotFactory

+ (BulbSlot *)buildWithSignals:(NSArray<BulbSignal *> *)signals fireTable:(NSDictionary *)identifier2status block:(BulbHasResultBlock)block filterBlock:(BulbFilterBlock)filterBlock
{
    BulbSlot* slot = [[BulbSlot alloc] initWithSignals:signals block:block fireTable:@[identifier2status]];
    slot.filterBlock = filterBlock;
    return slot;
}

@end
