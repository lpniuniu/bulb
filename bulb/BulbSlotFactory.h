//
//  BulbRegister.h
//  bulb
//
//  Created by FanFamily on 16/8/12.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulbSlot.h"
#import "BulbSignal.h"

/*!
 *  @brief 信号槽构建工厂
 */
@interface BulbSlotFactory : NSObject

+ (BulbSlot *)buildWithSignals:(NSArray<BulbSignal *> *)signals fireTable:(NSDictionary *)identifier2status block:(BulbHasResultBlock)block filterBlock:(BulbFilterBlock)filterBlock;

@end
