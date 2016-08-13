//
//  BulbSignal.m
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbSignal.h"
#import "BulbConstant.h"

@implementation BulbSignal

- (instancetype)initWithSignalIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _status = kBulbSignalStatusOff;
    }
    return self;
}

-(NSUInteger)hash
{
    return [_identifier hash];
}

- (BOOL)isEqual:(BulbSignal *)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[BulbSignal class]]) {
        return NO;
    }
    
    return [self.identifier isEqualToString:object.identifier] && [self.status isEqualToString:object.status];
}

- (void)reset
{
    _status = kBulbSignalStatusOff;
}

@end
