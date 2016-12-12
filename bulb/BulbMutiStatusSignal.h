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
+ (instancetype)signalRecoverFromHungUpWithStatus:(NSString *)status; // 含义见 HungUpType
+ (instancetype)signalPickOffFromHungUpWithStatus:(NSString *)status; // 含义见 HungUpType

- (void)setStatus:(NSString *)status;

- (NSString *)status;

- (void)off;

@end
