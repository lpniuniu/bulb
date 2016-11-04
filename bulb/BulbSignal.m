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
    return [NSString stringWithFormat:@"Bulb_%@", self.class];
}

- (NSString *)identifier
{
    return [self.class identifier];
}

- (void)reset
{
    [self doesNotRecognizeSelector:_cmd];
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

@end

