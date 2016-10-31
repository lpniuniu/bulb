//
//  BulbTests.m
//  BulbTests
//
//  Created by FanFamily on 16/8/13.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Bulb.h"

@interface BulbTextDealloc : NSObject

@end

@implementation BulbTextDealloc

- (void)dealloc
{
    NSLog(@"A dealloc .");
}

@end

@interface BulbTests : XCTestCase

@end

@implementation BulbTests


- (void)testRegister {
    NSString* noti = @"noti A";
    [[Bulb bulbGlobal] registerSignals:@[noti] block:^(id data, NSDictionary<NSString *,id> *signalIdentifier2data) {
        NSLog(@"noti exe ! %@", data);
        XCTAssertNotNil(data);
    }];
    [[Bulb bulbGlobal] fire:noti data:@"data"];
}

- (void)testWeakDataWrapper
{
    [[Bulb bulbGlobal] registerSignals:@[@"A", @"B"] block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        NSLog(@"noti exe ! %@", firstData);
        XCTAssert(firstData == nil);
        XCTAssert(signalIdentifier2data.count == 1);
    }];
    
    @autoreleasepool {
        BulbTextDealloc* a = [[BulbTextDealloc alloc] init];
        [[Bulb bulbGlobal] fire:@"A" data:[BulbWeakDataWrapper wrap:a]];
    }
    [[Bulb bulbGlobal] fire:@"B" data:@"data"];
}

- (void)testBulbNameEqual
{
    XCTAssert([Bulb bulbGlobal] == [Bulb bulbGlobal]);
    XCTAssert([Bulb bulbWithName:@"new_bulb_name"] == [Bulb bulbWithName:@"new_bulb_name"]);
}

@end
