//
//  BulbSignal.m
//  bulb
//
//  Created by FanFamily on 2016/11/1.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbSignal.h"

@implementation BulbSignal

+ (NSString *)identifier
{
    return [NSString stringWithFormat:@"Bulb_%@", NSStringFromClass(self.class)];
}

+ (NSString *)identifierWithClassify:(NSString *)classify
{
    return [NSString stringWithFormat:@"%@_%@", [self.class identifier], classify];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _originStatus = kBulbSignalStatusNone;
    }
    return self;
}

- (NSString *)identifier
{
    if (self.identifierClassify.length > 0) {
        return [NSString stringWithFormat:@"%@_%@", [self.class identifier], self.identifierClassify];
    } else {
        return [self.class identifier];
    }
}

- (void)reset
{
    self.data = nil;
    self.originData = nil;
    self.originStatus = kBulbSignalStatusNone;
}

-(NSUInteger)hash
{
    return [[self.class identifier] hash];
}

- (BOOL)isEqual:(BulbSignal *)object {
    if (self == object) {
        return YES;
    }
    
    if (![[object identifier] isEqualToString:[self identifier]]) {
        return NO;
    }
    
    return self.status == object.status;
}

- (NSString *)description
{
    NSString* result = [self.class description];
    result = [result stringByAppendingString:[NSString stringWithFormat:@" status:%ld", self.status]];
    result = [result stringByAppendingString:[NSString stringWithFormat:@" origin_status:%ld", self.originStatus]];
    result = [result stringByAppendingString:[NSString stringWithFormat:@" data:%@", self.data]];
    result = [result stringByAppendingString:[NSString stringWithFormat:@" origin_data:%@", self.originData]];
    return result;
}

-(void)setStatus:(NSInteger)status
{
    if(self.originStatus == kBulbSignalStatusNone) {
        self.originStatus = status;
    } else if (self.status) {
        self.originStatus = self.status;
    }
    _status = status;
}

-(void)setData:(id)data
{
    if (self.originData == nil) {
        self.originData = data;
    } else if (self.data) {
        self.originData = self.data;
    }
    _data = data;
}

@end

