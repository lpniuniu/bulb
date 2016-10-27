//
//  NSArray+BBDistinct.m
//  bulb
//
//  Created by FanFamily on 2016/10/27.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "NSArray+BBDistinct.h"

@implementation NSArray (BBDistinct)

- (NSArray *)bb_distinct
{
    NSMutableArray* array = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![array containsObject:obj]) {
            [array addObject:obj];
        }
    }];
    return array;
}

@end
