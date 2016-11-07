//
//  BulbTests.m
//  BulbTests
//
//  Created by FanFamily on 16/8/13.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Bulb.h"
#import "BulbTestRegisterSignal.h"
#import "BulbTestRegisterMutiStatusSignal.h"
#import "BulbTestRegisterMutiStatusSignal1.h"
#import "BulbRecorder.h"

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
    [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterSignal signal] block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        testRegister_signal_fire = @"testRegister_signal_fire";
        NSLog(@"testRegister_signal data %@", firstData);
        XCTAssert([firstData isEqualToString:@"data"]);
    }];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:@"data"];
    XCTAssert([testRegister_signal_fire isEqualToString:@"testRegister_signal_fire"]);
    // once test
    testRegister_signal_fire = nil;
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:@"data"];
    XCTAssert(testRegister_signal_fire == nil);
    
    [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterMutiStatusSignal signalWithStatus:@"status1"] block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        NSLog(@"testRegister_signal status1 data %@", firstData);
        XCTAssert([firstData isEqualToString:@"data1"]);
    }];
    
    [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterMutiStatusSignal signalWithStatus:@"status2"] block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        NSLog(@"testRegister_signal status2 data %@", firstData);
        XCTAssert([firstData isEqualToString:@"data2"]);
    }];

    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:@"status1"] data:@"data1"];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:@"status2"] data:@"data2"];
}

- (void)testRegisterJoinSignals
{
    __block id testRegister_signal1_and_signal2_fire;
    [[Bulb bulbGlobal] registerSignals:@[[BulbTestRegisterMutiStatusSignal signalWithStatus:@"status1"],[BulbTestRegisterMutiStatusSignal1 signalWithStatus:@"status2"]] block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        testRegister_signal1_and_signal2_fire = @"signal1 and signal2 fire";
        NSLog(@"testRegister signal1 and signal2 fire, %@", signalIdentifier2data);
        XCTAssert(signalIdentifier2data.count == 2);
        XCTAssert([firstData isEqualToString:@"data1"]);
    }];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:@"status1"] data:@"data1"];
    XCTAssert(testRegister_signal1_and_signal2_fire == nil);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal1 signalWithStatus:@"status2"] data:@"data2"];
    XCTAssert(testRegister_signal1_and_signal2_fire != nil);
    
    // three 信号
    testRegister_signal1_and_signal2_fire = nil;
    [[Bulb bulbGlobal] registerSignals:@[[BulbTestRegisterSignal signal], [BulbTestRegisterMutiStatusSignal signalWithStatus:@"status1"],[BulbTestRegisterMutiStatusSignal1 signalWithStatus:@"status2"]] block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        testRegister_signal1_and_signal2_fire = @"signal1 and signal2 fire";
        NSLog(@"testRegister signal1 and signal2 fire, %@", signalIdentifier2data);
        XCTAssert(signalIdentifier2data.count == 3);
        XCTAssert([firstData isEqualToString:@"data"]);
    }];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:@"data"];
    XCTAssert(testRegister_signal1_and_signal2_fire == nil);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:@"status1"] data:@"data1"];
    XCTAssert(testRegister_signal1_and_signal2_fire == nil);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal1 signalWithStatus:@"status2"] data:@"data2"];
    XCTAssert(testRegister_signal1_and_signal2_fire != nil);
}

- (void)testRegisterForeverBlock
{
    __block NSInteger testRegister_signal_forever_fire_times = 0;
    [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterSignal signal] foreverblock:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        testRegister_signal_forever_fire_times++;
        return YES;
    }];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:@"data"];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:@"data"];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:@"data"];
    XCTAssert(testRegister_signal_forever_fire_times == 3);
}

- (void)testRegisterForeverBlockCancel
{
    __block NSInteger testRegister_signal_forever_fire_times = 0;
    [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterSignal signal] foreverblock:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        testRegister_signal_forever_fire_times++;
        if (testRegister_signal_forever_fire_times == 2) {
            return NO;
        }
        return YES;
    }];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:@"data"];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:@"data"];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:@"data"];
    XCTAssert(testRegister_signal_forever_fire_times == 2);
}


- (void)testSaveList
{
    [[Bulb bulbGlobal] fireAndSave:[BulbTestRegisterSignal signal] data:@"data1"];
    
    BulbSignal* signal = [[Bulb bulbGlobal] getSignalFromSaveList:[BulbTestRegisterSignal identifier]];
    XCTAssert([signal.status isEqualToString:kBulbSignalStatusOn]);
    
    [[Bulb bulbGlobal] save:[BulbTestRegisterSignal signalWithOn:NO] data:nil];
    
    signal = [[Bulb bulbGlobal] getSignalFromSaveList:[BulbTestRegisterSignal identifier]];
    XCTAssert([signal.status isEqualToString:kBulbSignalStatusOff]);
}

- (void)testInitFromSave
{
    [[Bulb bulbGlobal] save:[BulbTestRegisterSignal signal] data:nil];
    __block id testRegister_init_from_save = nil;
    BulbSlot* slot = [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterSignal signalInitFromSave] block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        testRegister_init_from_save = @"not null";
    }];
    BulbSignal* signal = slot.signals.firstObject;
    XCTAssert(signal != nil);
    XCTAssert(signal.status == kBulbSignalStatusOn);
    XCTAssert(testRegister_init_from_save != nil);
    testRegister_init_from_save = nil;
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:nil];
    XCTAssert(testRegister_init_from_save == nil);
    
    // forever
    slot = [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterSignal signalInitFromSave] foreverblock:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        testRegister_init_from_save = @"not null";
        return YES;
    }];
    XCTAssert(signal != nil);
    XCTAssert(signal.status == kBulbSignalStatusOn);
    XCTAssert(testRegister_init_from_save != nil);
    testRegister_init_from_save = nil;
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:nil];
    XCTAssert(testRegister_init_from_save != nil);
    
    testRegister_init_from_save = nil;
    [[Bulb bulbGlobal] remove:[BulbTestRegisterSignal signalInitFromSave]];
    [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterSignal signalInitFromSave] block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        testRegister_init_from_save = @"not null";
    }];
    XCTAssert(testRegister_init_from_save == nil);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:nil];
    XCTAssert(testRegister_init_from_save != nil);
    
    testRegister_init_from_save = nil;
    [[Bulb bulbGlobal] save:[BulbTestRegisterMutiStatusSignal signalWithStatus:@"status"] data:nil];
    [[Bulb bulbGlobal] registerSignals:@[[BulbTestRegisterMutiStatusSignal signalInitFromSaveWithStatus:@"status"], [BulbTestRegisterMutiStatusSignal1 signalWithStatus:@"status1"]] block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        testRegister_init_from_save = @"not null";
    }];
    XCTAssert(testRegister_init_from_save == nil);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal1 signalInitFromSaveWithStatus:@"status1"] data:nil];
    XCTAssert(testRegister_init_from_save != nil);
    
    testRegister_init_from_save = nil;
    [[Bulb bulbGlobal] save:[BulbTestRegisterMutiStatusSignal1 signalWithStatus:@"status1"] data:nil];
    [[Bulb bulbGlobal] registerSignals:@[[BulbTestRegisterMutiStatusSignal signalInitFromSaveWithStatus:@"status"], [BulbTestRegisterMutiStatusSignal1 signalInitFromSaveWithStatus:@"status1"]] foreverblock:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        testRegister_init_from_save = @"not null";
        return YES;
    }];
    XCTAssert(testRegister_init_from_save != nil);
    
    testRegister_init_from_save = nil;
    [[Bulb bulbGlobal] remove:[BulbTestRegisterMutiStatusSignal1 signalWithStatus:@"status1"]];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalInitFromSaveWithStatus:@"status"] data:nil];
    XCTAssert(testRegister_init_from_save == nil);
}

- (void)testWeakDataWrapper
{
    [[Bulb bulbGlobal] registerSignals:@[[BulbTestRegisterSignal signal], [BulbTestRegisterMutiStatusSignal signalWithStatus:@"status1"]] block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        NSLog(@"noti exe ! %@", firstData);
        XCTAssert(firstData == nil);
        XCTAssert(signalIdentifier2data.count == 1);
    }];
    
    @autoreleasepool {
        BulbTextDealloc* a = [[BulbTextDealloc alloc] init];
        [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:[BulbWeakDataWrapper wrap:a]];
    }
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:@"status1"] data:@"data"];
}

- (void)testBulbNameEqual
{
    XCTAssert([Bulb bulbGlobal] == [Bulb bulbGlobal]);
    XCTAssert([Bulb bulbWithName:@"new_bulb_name"] == [Bulb bulbWithName:@"new_bulb_name"]);
}

- (void)testFilter
{
    __block id testRegister_signal_fire = nil;
    [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterSignal signal] block:^(id firstData, NSDictionary<NSString *,id> *signalIdentifier2data) {
        testRegister_signal_fire = @"testRegister_signal_fire";
        NSLog(@"testRegister_signal data %@", firstData);
    } filterBlock:^BOOL(BulbSignal *signal) {
        if ([signal.data isEqualToString:@"data"]) {
            return YES;
        }
        return NO;
    }];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:@"data"];
    XCTAssert(![testRegister_signal_fire isEqualToString:@"testRegister_signal_fire"]);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signal] data:@"data1"];
    XCTAssert([testRegister_signal_fire isEqualToString:@"testRegister_signal_fire"]);
}

- (void)testRecorder
{
    [BulbTestRegisterSignal signal];
    [BulbTestRegisterMutiStatusSignal signalWithStatus:@"status1"];
    [BulbTestRegisterMutiStatusSignal1 signalWithStatus:@"status2"];
    
    NSString* allSignals = [[BulbRecorder sharedInstance] allSignals];
    NSLog(@"%@", allSignals);
    XCTAssert(allSignals != nil);
}

@end
