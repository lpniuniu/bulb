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

+ (instancetype)signalWithOn:(BOOL)on;

- (void)on;
- (void)off;

- (BOOL)isOn;

@end
