//
//  BulbMutiStatusSignal.m
//  bulb
//
//  Created by FanFamily on 2016/11/1.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbMutiStatusSignal.h"
#import "BulbRecorder+Private.h"

@implementation BulbMutiStatusSignal

+(void)initialize
{
    if ([self class] != [BulbMutiStatusSignal class]) {
        [[BulbRecorder sharedInstance] addSignalsRecord:[self description]];
    }
}

+ (instancetype)signalWithStatus:(NSString *)status
{
    BulbMutiStatusSignal* signal = [[self alloc] init];
    [signal setStatus:status];
    signal.recoverStatusFromHungUp = NO;
    return signal;
}

+ (instancetype)signalRecoverFromHungUpWithStatus:(NSString *)status
{
    BulbMutiStatusSignal* signal = [[self alloc] init];
    [signal setStatus:status];
    signal.recoverStatusFromHungUp = YES;
    return signal;
}

- (void)reset
{
    self.status = kBulbSignalStatusOff;
    [super reset];
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
