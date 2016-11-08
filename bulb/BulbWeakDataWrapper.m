//
//  BulbWeakData.m
//  bulb
//
//  Created by FanFamily on 2016/10/27.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbWeakDataWrapper.h"

@implementation BulbWeakDataWrapper

- (instancetype)initWithData:(id)data
{
    self = [super init];
    if (self) {
        _internalData = data;
    }
    return self;
}

+ (id)wrap:(id)data
{
    return [[BulbWeakDataWrapper alloc] initWithData:data];
}

+ (id)unwrapperData:(id)origindata
{
    id data = nil;
    if (origindata) {
        if ([origindata isKindOfClass:[BulbWeakDataWrapper class]]) {
            BulbWeakDataWrapper* weakDataWrapper = (BulbWeakDataWrapper *)origindata;
            if (weakDataWrapper.internalData) {
                data = weakDataWrapper.internalData;
            } else {
                data = nil;
            }
        } else {
            data = origindata;
        }
    }
    return data;
}

-(NSString *)description
{
    NSString* result = [self.class description];
    result = [result stringByAppendingString:[NSString stringWithFormat:@" internalData:%@", self.internalData]];
    return result;
}


@end
