//
//  BulbMutiStatusSignal.m
//  bulb
//
//  Created by FanFamily on 2016/11/1.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbMutiStatusSignal.h"

@implementation BulbMutiStatusSignal

+ (instancetype)signal
{
    BulbMutiStatusSignal* signal = [[self alloc] init];
    [signal off];
    return signal;
}

+ (instancetype)signalWithStatus:(NSString *)status
{
    BulbMutiStatusSignal* signal = [[self alloc] init];
    signal.status = status;
    return signal;
}

- (void)reset
{
    self.status = kBulbSignalStatusOff;
}

- (void)off
{
    self.status = kBulbSignalStatusOff;
}

- (void)setStatus:(NSString *)status
{
    [super setStatus:status];
}

- (NSString *)status
{
    return [super status];
}

@end
