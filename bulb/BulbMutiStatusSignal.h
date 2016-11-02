//
//  BulbMutiStatusSignal.h
//  bulb
//
//  Created by FanFamily on 2016/11/1.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbSignal.h"

@interface BulbMutiStatusSignal : BulbSignal

+ (instancetype)signal;

+ (instancetype)signalWithStatus:(NSString *)status;

- (void)setStatus:(NSString *)status;

- (NSString *)status;

- (void)off;

@end
