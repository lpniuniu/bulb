//
//  BulbMutiStatusSignal.h
//  bulb
//
//  Created by FanFamily on 2016/11/1.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbSignal.h"

@interface BulbMutiStatusSignal : BulbSignal

+ (instancetype)signalWithStatus:(NSInteger)status;
+ (instancetype)signalWithStatus:(NSInteger)status classify:(NSString *)classify;
// 链式初始化
- (instancetype)recoverFromHungUp; // 含义见 HungUpType
- (instancetype)pickOffFromHungUp; // 含义见 HungUpType

- (void)setStatus:(NSInteger)status;
- (NSInteger)status;

@end
