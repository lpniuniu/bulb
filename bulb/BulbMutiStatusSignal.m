//
//  BulbMutiStatusSignal.m
//  bulb
//
//  Created by FanFamily on 2016/11/1.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbMutiStatusSignal.h"

@implementation BulbMutiStatusSignal

+ (instancetype)signalWithStatus:(NSString *)status
{
    BulbMutiStatusSignal* signal = [[self alloc] init];
    [signal setStatus:status];
    signal.initialStatusFromSave = NO;
    return signal;
}

+ (instancetype)signalWithStatus:(NSString *)status initFromSave:(BOOL)fromSave
{
    BulbMutiStatusSignal* signal = [[self alloc] init];
    [signal setStatus:status];
    signal.initialStatusFromSave = fromSave;
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
