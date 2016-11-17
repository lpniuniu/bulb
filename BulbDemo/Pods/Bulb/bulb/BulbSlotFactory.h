//
//  BulbRegister.h
//  bulb
//
//  Created by FanFamily on 16/8/12.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulbSlot.h"
#import "BulbOnceSlot.h"
#import "BulbSignal.h"

/*!
 *  @brief 信号槽构建工厂
 */
@interface BulbSlotFactory : NSObject

/*
 *  构造BulbOnceSlot
 */
+ (BulbSlot *)buildWithSignals:(NSArray<BulbSignal *> *)signals fireTable:(NSDictionary *)identifier2status block:(BulbBlock)block filterBlock:(BulbFilterBlock)filterBlock;

/*
 *  构造标准的BulbSlot
 */
+ (BulbSlot *)buildWithSignals:(NSArray<BulbSignal *> *)signals fireTable:(NSDictionary *)identifier2status foreverBlock:(BulbHasResultBlock)foreverBlock filterBlock:(BulbFilterBlock)filterBlock;

@end
