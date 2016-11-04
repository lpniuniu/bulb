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
+ (instancetype)signalWithInitFromSave:(BOOL)fromSave;
+ (instancetype)signalWithOn:(BOOL)on;
+ (instancetype)signalWithOn:(BOOL)on initFromSave:(BOOL)fromSave;

- (void)on;
- (void)off;

- (BOOL)isOn;

@end
