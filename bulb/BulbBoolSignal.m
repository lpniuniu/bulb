//
//  BulbSignal.m
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbBoolSignal.h"
#import "BulbRecorder+Private.h"

@implementation BulbBoolSignal

+(void)initialize
{
    if ([self class] != [BulbBoolSignal class]) {
        [[BulbRecorder sharedInstance] addSignalsRecord:[self description]];
    }
}

+ (instancetype)signal
{
    BulbBoolSignal* signal = [[self alloc] init];
    [signal on];
    signal.hungUpBehavior = kHungUpTypeNone;
    return signal;
}

+ (instancetype)signalRecoverFromHungUp
{
    BulbBoolSignal* signal = [[self alloc] init];
    [signal on];
    signal.hungUpBehavior = kHungUpTypeRecover;
    return signal;
}

+ (instancetype)signalWithOn:(BOOL)on
{
    BulbBoolSignal* signal = [[self alloc] init];
    on?[signal on]:[signal off];
    signal.hungUpBehavior = kHungUpTypeNone;
    return signal;
}

+ (instancetype)signalRecoverFromHungUpWithOn:(BOOL)on
{
    BulbBoolSignal* signal = [[self alloc] init];
    on?[signal on]:[signal off];
    signal.hungUpBehavior = kHungUpTypeRecover;
    return signal;
}

+ (instancetype)signalPickOffFromHungUpWithOn:(BOOL)on
{
    BulbBoolSignal* signal = [[self alloc] init];
    on?[signal on]:[signal off];
    signal.hungUpBehavior = kHungUpTypePickOff;
    return signal;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.status = kBulbSignalStatusOff;
    }
    return self;
}

- (void)on;
{
    self.status = kBulbSignalStatusOn;
}

- (void)off
{
    self.status = kBulbSignalStatusOff;
}

- (BOOL)isOn
{
    return self.status == kBulbSignalStatusOn?YES:NO;
}

- (void)reset
{
    [self off];
    [super reset];
}

@end
