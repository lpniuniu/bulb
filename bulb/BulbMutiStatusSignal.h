//
//  BulbMutiStatusSignal.h
//  bulb
//
//  Created by FanFamily on 2016/11/1.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbSignal.h"

@interface BulbMutiStatusSignal : BulbSignal

+ (instancetype)signalWithStatus:(NSString *)status;
+ (instancetype)signalWithStatus:(NSString *)status classify:(NSString *)classify;
// 链式初始化
- (instancetype)recoverFromHungUp; // 含义见 HungUpType
- (instancetype)pickOffFromHungUp; // 含义见 HungUpType

- (void)setStatus:(NSString *)status;
- (NSString *)status;
- (void)off;

@end
