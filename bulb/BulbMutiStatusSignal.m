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
    signal.hungUpBehavior = kHungUpTypeNone;
    return signal;
}

+ (instancetype)signalWithStatus:(NSString *)status classify:(NSString *)classify
{
    BulbMutiStatusSignal* signal = [BulbMutiStatusSignal signalWithStatus:status];
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
