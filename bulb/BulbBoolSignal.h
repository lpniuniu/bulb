//
//  BulbSignal.h
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulbSignal.h"
/*!
 *  @brief 信号
 */
@interface BulbBoolSignal : BulbSignal

+ (instancetype)signal;
+ (instancetype)signalRecoverFromHungUp;
+ (instancetype)signalWithOn:(BOOL)on;
+ (instancetype)signalRecoverFromHungUpWithOn:(BOOL)on; // 含义见 HungUpType
+ (instancetype)signalPickOffFromHungUpWithOn:(BOOL)on; // 含义见 HungUpType

- (void)on;
- (void)off;

- (BOOL)isOn;

@end
