//
//  BulbOnceSlot.h
//  bulb
//
//  Created by FanFamily on 2016/11/6.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbSlot.h"

/*!
 *  @brief 信号槽，容纳信号，当满足条件被fire，从队列中移除
 */
@interface BulbOnceSlot : BulbSlot

- (instancetype)initWithSignals:(NSArray<BulbSignal *> *)signals block:(BulbBlock)block fireTable:(NSArray<NSDictionary<NSString *, NSString *>*>* )fireTable;

@end
