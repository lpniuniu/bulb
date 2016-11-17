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

- (NSString *)identifier
{
    return [self.class identifier];
}

- (void)reset
{
    self.data = nil;
    self.originData = nil;
    self.originStatus = nil;
}

-(NSUInteger)hash
{
    return [[self.class identifier] hash];
}

- (BOOL)isEqual:(BulbSignal *)object {
    if (self == object) {
        return YES;
    }
    
    if (![[object.class identifier] isEqualToString:[self.class identifier]]) {
        return NO;
    }
    
    return [self.status isEqualToString:object.status];
}

- (NSString *)description
{
    NSString* result = [self.class description];
    result = [result stringByAppendingString:[NSString stringWithFormat:@" status:%@", self.status]];
    result = [result stringByAppendingString:[NSString stringWithFormat:@" origin_status:%@", self.originStatus]];
    result = [result stringByAppendingString:[NSString stringWithFormat:@" data:%@", self.data]];
    result = [result stringByAppendingString:[NSString stringWithFormat:@" origin_data:%@", self.originData]];
    return result;
}

-(void)setStatus:(NSString *)status
{
    if(self.originStatus == nil) {
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

