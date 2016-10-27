//
//  BulbTests.m
//  BulbTests
//
//  Created by FanFamily on 16/8/13.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Bulb.h"

@interface A : NSObject

@end

@implementation A

- (void)dealloc
{
    NSLog(@"A dealloc .");
}

@end

@interface BulbTests : XCTestCase

@end

@implementation BulbTests


- (void)test {
    NSString* noti = @"noti A";
    [Bulb regiseterSignals:@[noti] block:^(id data, NSDictionary<NSString *,id> *signalIdentifier2data) {
        NSLog(@"noti exe ! %@", data);
        XCTAssertNotNil(data);
    }];
    
    [Bulb runAfterSignal:noti block:^(id data, NSDictionary<NSString *,id> *signalIdentifier2data) {
        NSLog(@"noti exe ! %@, after", data);
        XCTAssertNotNil(data);
    }];
    [Bulb fire:noti data:@"data"];
}

- (void)testWeakDataWrapper
{
    [Bulb regiseterSignals:@[@"A", @"B"] block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        NSLog(@"noti exe ! %@", firstData);
        XCTAssert(firstData == nil);
        XCTAssert(signalIdentifier2data.count == 1);
    }];
    
    @autoreleasepool {
        A* a = [[A alloc] init];
        [Bulb fire:@"A" data:[BulbWeakDataWrapper wrap:a]];
    }
    [Bulb fire:@"B" data:@"data"];
}

@end
