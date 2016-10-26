//
//  BulbTests.m
//  BulbTests
//
//  Created by FanFamily on 16/8/13.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Bulb.h"

@interface BulbTests : XCTestCase

@end

@implementation BulbTests



- (void)test {
    NSString* noti = @"noti A";
    [Bulb regiseterSignals:@[noti] block:^(id data, NSMapTable<NSString *,id> *fireDataTable) {
        NSLog(@"noti exe ! %@", data);
    }];
    
    [Bulb runAfterSignal:noti block:^(id data, NSMapTable<NSString *,id> *fireDataTable) {
        NSLog(@"noti exe ! %@, after", data);
    }];
    [Bulb fire:noti data:@"data"];
}

@end
