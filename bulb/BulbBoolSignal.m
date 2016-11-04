//
//  BulbSignal.m
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbBoolSignal.h"

@implementation BulbBoolSignal

+ (instancetype)signal
{
    BulbBoolSignal* signal = [[self alloc] init];
    [signal on];
    signal.initialStatusFromSave = NO;
    return signal;
}

+ (instancetype)signalWithInitFromSave:(BOOL)fromSave
{
    BulbBoolSignal* signal = [[self alloc] init];
    [signal on];
    signal.initialStatusFromSave = fromSave;
    return signal;
}

+ (instancetype)signalWithOn:(BOOL)on
{
    BulbBoolSignal* signal = [[self alloc] init];
    on?[signal on]:[signal off];
    signal.initialStatusFromSave = NO;
    return signal;
}

+ (instancetype)signalWithOn:(BOOL)on initFromSave:(BOOL)fromSave
{
    BulbBoolSignal* signal = [[self alloc] init];
    on?[signal on]:[signal off];
    signal.initialStatusFromSave = fromSave;
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
}

@end
