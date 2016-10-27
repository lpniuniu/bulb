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

@end
