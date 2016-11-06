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
 *  @brief 注册信号，填充槽
 */
@interface BulbSlotFactory : NSObject

/*
 *  构造全明槽，只有一个fireTable，信号全部匹配fireTable，block调用
 */
+ (BulbSlot *)buildWithSignals:(NSArray<BulbSignal *> *)signals fireTable:(NSDictionary *)identifier2status block:(BulbBlock)block filterBlock:(BulbFilterBlock)filterBlock;

+ (BulbSlot *)buildWithSignals:(NSArray<BulbSignal *> *)signals fireTable:(NSDictionary *)identifier2status foreverBlock:(BulbHasResultBlock)foreverBlock filterBlock:(BulbFilterBlock)filterBlock;

@end
