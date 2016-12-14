//
//  BulbSignal.m
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbBoolSignal.h"
#import "BulbRecorder+Private.h"

typedef enum : NSInteger {
    kBulbBoolSignalStatusOff,
    kBulbBoolSignalStatusOn
} BulbBoolSignalStatus;

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

+ (instancetype)signalWithClassify:(NSString *)classify
{
    BulbBoolSignal* signal = [BulbBoolSignal signal];
    signal.identifierClassify = classify;
    return signal;
}

- (instancetype)recoverFromHungUp
{
    self.hungUpBehavior = kHungUpTypeRecover;
    return self;
}

- (instancetype)pickOffFromHungUp
{
    self.hungUpBehavior = kHungUpTypePickOff;
    return self;
}

- (instancetype)classify:(NSString *)classify
{
    self.identifierClassify = classify;
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.status = kBulbBoolSignalStatusOff;
    }
    return self;
}

- (instancetype)on;
{
    self.status = kBulbBoolSignalStatusOn;
    return self;
}

- (instancetype)off
{
    self.status = kBulbBoolSignalStatusOff;
    return self;
}

- (BOOL)isOn
{
    return self.status == kBulbBoolSignalStatusOn?YES:NO;
}

- (void)reset
{
    [self off];
    [super reset];
}

@end
