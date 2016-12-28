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

+ (instancetype)signalDefault;
+ (instancetype)signalWithClassify:(NSString *)classify;
// 链式初始化
- (instancetype)on;
- (instancetype)off;
- (instancetype)recoverFromHungUp; // 含义见 HungUpType
- (instancetype)pickOffFromHungUp; // 含义见 HungUpType

- (BOOL)isOn;

@end
