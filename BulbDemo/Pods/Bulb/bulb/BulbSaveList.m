//
//  BulbSaveList.m
//  bulb
//
//  Created by FanFamily on 16/8/12.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbSaveList.h"

@implementation BulbSaveList

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.signals = [NSMutableArray array];
    }
    return self;
}

@end
