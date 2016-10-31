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

    __block id testRegister_signal_fire;
    [[Bulb bulbGlobal] registerSignal:@"testRegister_signal" block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        testRegister_signal_fire = @"testRegister_signal_fire";
        NSLog(@"testRegister_signal data %@", firstData);
        XCTAssert([firstData isEqualToString:@"data"]);
    }];
    [[Bulb bulbGlobal] fire:@"testRegister_signal" data:@"data"];
    XCTAssert([testRegister_signal_fire isEqualToString:@"testRegister_signal_fire"]);
    
    [[Bulb bulbGlobal] registerSignal:@"testRegister_signal" status:@"status1" block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        NSLog(@"testRegister_signal status1 data %@", firstData);
        XCTAssert([firstData isEqualToString:@"data1"]);
    }];
    
    [[Bulb bulbGlobal] registerSignal:@"testRegister_signal" status:@"status2" block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        NSLog(@"testRegister_signal status2 data %@", firstData);
        XCTAssert([firstData isEqualToString:@"data2"]);
    }];
    
    [[Bulb bulbGlobal] fire:@"testRegister_signal" status:@"status1" data:@"data1"];
    [[Bulb bulbGlobal] fire:@"testRegister_signal" status:@"status2" data:@"data2"];
    
    __block id testRegister_signal1_and_signal2_fire;
    [[Bulb bulbGlobal] registerSignals:@[@"testRegister_signal1", @"testRegister_signal2"] block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        testRegister_signal1_and_signal2_fire = @"signal1 and signal2 fire";
        NSLog(@"testRegister signal1 and signal2 fire, %@", signalIdentifier2data);
        XCTAssert(signalIdentifier2data.count == 2);
        XCTAssert([firstData isEqualToString:@"data1"]);
    }];
    
    [[Bulb bulbGlobal] fire:@"testRegister_signal1" data:@"data1"];
    XCTAssert(testRegister_signal1_and_signal2_fire == nil);
    [[Bulb bulbGlobal] fire:@"testRegister_signal2" data:@"data2"];
    XCTAssert(testRegister_signal1_and_signal2_fire != nil);
    
    /* ----------------- forever register test --------------*/
    testRegister_signal_fire = nil;
    [[Bulb bulbGlobal] fire:@"testRegister_signal" data:@"data"];
    [[Bulb bulbGlobal] fire:@"testRegister_signal" data:@"data"];
    [[Bulb bulbGlobal] fire:@"testRegister_signal" data:@"data"];
    XCTAssert(testRegister_signal_fire == nil);
    
    __block NSInteger testRegister_signal_forever_fire_times = 0;
    [[Bulb bulbGlobal] registerSignal:@"testRegister_signal_forever" foreverblock:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        testRegister_signal_forever_fire_times++;
    }];
    [[Bulb bulbGlobal] fire:@"testRegister_signal_forever" data:@"data"];
    [[Bulb bulbGlobal] fire:@"testRegister_signal_forever" data:@"data"];
    [[Bulb bulbGlobal] fire:@"testRegister_signal_forever" data:@"data"];
    XCTAssert(testRegister_signal_forever_fire_times == 3);
    
}

- (void)testRegisterIfNotSave {
    [[Bulb bulbGlobal] save:@"testRegisterIfNotSave_signal" data:@"testRegisterIfNotSave_signal_data"];
    __block id testRegisterIfNotSave_signal_forever_fire;
    [[Bulb bulbGlobal] registerSignalIfNotSave:@"testRegisterIfNotSave_signal" block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        XCTAssert([firstData isEqualToString:@"testRegisterIfNotSave_signal_data"]);
        testRegisterIfNotSave_signal_forever_fire = @"testRegisterIfNotSave_signal_forever_fire";
    }];
    XCTAssert([testRegisterIfNotSave_signal_forever_fire isEqualToString:@"testRegisterIfNotSave_signal_forever_fire"]);
    
    //  change sort
    testRegisterIfNotSave_signal_forever_fire = nil;
    [[Bulb bulbGlobal] registerSignalIfNotSave:@"testRegisterIfNotSave_signal_change_sort" block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        XCTAssert([firstData isEqualToString:@"testRegisterIfNotSave_signal_data"]);
        testRegisterIfNotSave_signal_forever_fire = @"testRegisterIfNotSave_signal_forever_fire";
    }];
    [[Bulb bulbGlobal] fireAndSave:@"testRegisterIfNotSave_signal_change_sort" data:@"testRegisterIfNotSave_signal_data"];
    XCTAssert([testRegisterIfNotSave_signal_forever_fire isEqualToString:@"testRegisterIfNotSave_signal_forever_fire"]);
    
}

- (void)testSaveList
{
    [[Bulb bulbGlobal] fireAndSave:@"testSaveList_signal1" data:@"data1"];
    [[Bulb bulbGlobal] save:@"testSaveList_signal2" data:@"data2"];
    [[Bulb bulbGlobal] save:@"testSaveList_signal3" data:@"data2"];
    
    NSString* status = [[Bulb bulbGlobal] getSignalStatusFromSaveList:@"testSaveList_signal3"];
    XCTAssert([status isEqualToString:kBulbSignalStatusOn]);
    
    [[Bulb bulbGlobal] save:@"testSaveList_signal3" status:kBulbSignalStatusOff data:nil];
    
    status = [[Bulb bulbGlobal] getSignalStatusFromSaveList:@"testSaveList_signal3"];
    XCTAssert([status isEqualToString:kBulbSignalStatusOff]);
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
