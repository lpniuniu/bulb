//
//  BulbHungUpList.h
//  bulb
//
//  Created by FanFamily on 16/8/12.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulbSignal.h"

/*!
 *  @brief 信号状态槽，bulb全局持有，保留一系列的状态，可用于查询和恢复某些信号状态
 */
@interface BulbHungUpList : NSObject

@property (nonatomic) NSMutableArray<BulbSignal *>* signals;

@end
