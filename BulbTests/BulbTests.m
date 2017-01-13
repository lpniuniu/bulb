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

static const NSInteger kSignalOn = 0;
static const NSInteger kSignalOff = -1;

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
    [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterSignal signalDefault] block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2Signal) {
        testRegister_signal_fire = @"testRegister_signal_fire";
        NSLog(@"testRegister_signal data %@", firstData);
        XCTAssert([firstData isEqualToString:@"data"]);
    }];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signalDefault] data:@"data"];
    XCTAssert([testRegister_signal_fire isEqualToString:@"testRegister_signal_fire"]);
    // once test
    testRegister_signal_fire = nil;
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signalDefault] data:@"data"];
    XCTAssert(testRegister_signal_fire == nil);
    
    // nest register
    __block NSInteger testRegister_signal_fire_count = 0;
    [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2Signal) {
        NSLog(@"testRegister_signal status1 data %@", firstData);
        testRegister_signal_fire_count++;
        XCTAssert([firstData isEqualToString:@"data1"]);
        
        [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus2] block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2Signal) {
            NSLog(@"testRegister_signal status2 data %@", firstData);
            testRegister_signal_fire_count++;
            XCTAssert([firstData isEqualToString:@"data2"]);
        }];
    }];
    
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] data:@"data1"];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus2] data:@"data2"];
    
    XCTAssert(testRegister_signal_fire_count == 2);
}

- (void)testRegisterJoinSignals
{
    __block id testRegister_signal1_and_signal2_fire;
    [[Bulb bulbGlobal] registerSignals:@[[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1],[BulbTestRegisterMutiStatusSignal1 signalWithStatus:kStatus2]] block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2Signal) {
        testRegister_signal1_and_signal2_fire = @"signal1 and signal2 fire";
        NSLog(@"testRegister signal1 and signal2 fire, %@", signalIdentifier2Signal);
        XCTAssert(signalIdentifier2Signal.count == 2);
        XCTAssert([firstData isEqualToString:@"data1"]);
    }];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] data:@"data1"];
    XCTAssert(testRegister_signal1_and_signal2_fire == nil);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal1 signalWithStatus:kStatus2] data:@"data2"];
    XCTAssert(testRegister_signal1_and_signal2_fire != nil);
    
    // three 信号
    testRegister_signal1_and_signal2_fire = nil;
    [[Bulb bulbGlobal] registerSignals:@[[BulbTestRegisterSignal signalDefault], [BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1],[BulbTestRegisterMutiStatusSignal1 signalWithStatus:kStatus2]] block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2Signal) {
        testRegister_signal1_and_signal2_fire = @"signal1 and signal2 fire";
        NSLog(@"testRegister signal1 and signal2 fire, %@", signalIdentifier2Signal);
        XCTAssert(signalIdentifier2Signal.count == 3);
        XCTAssert([firstData isEqualToString:@"data"]);
    }];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signalDefault] data:@"data"];
    XCTAssert(testRegister_signal1_and_signal2_fire == nil);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] data:@"data1"];
    XCTAssert(testRegister_signal1_and_signal2_fire == nil);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal1 signalWithStatus:kStatus2] data:@"data2"];
    XCTAssert(testRegister_signal1_and_signal2_fire != nil);
}

- (void)testRegisterblock
{
    __block NSInteger testRegister_signal_forever_fire_times = 0;
    [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterSignal signalDefault] block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2Signal) {
        testRegister_signal_forever_fire_times++;
        return YES;
    }];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signalDefault] data:@"data"];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signalDefault] data:@"data"];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signalDefault] data:@"data"];
    XCTAssert(testRegister_signal_forever_fire_times == 3);
    
    __block NSInteger testRegister_signal1_and_signal2_fire_count = 0;
    [[Bulb bulbGlobal] registerSignals:@[[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1],[BulbTestRegisterMutiStatusSignal1 signalWithStatus:kStatus2]] block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2Signal) {
        testRegister_signal1_and_signal2_fire_count++;
        NSLog(@"testRegister signal1 and signal2 fire, %@", signalIdentifier2Signal);
        XCTAssert(signalIdentifier2Signal.count == 2);
        XCTAssert([firstData isEqualToString:@"data1"]);
        return YES;
    }];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] data:@"data1"];
    XCTAssert(testRegister_signal1_and_signal2_fire_count == 0);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal1 signalWithStatus:kStatus2] data:@"data2"];
    XCTAssert(testRegister_signal1_and_signal2_fire_count == 1);
    
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] data:@"data1"];
    XCTAssert(testRegister_signal1_and_signal2_fire_count == 1);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal1 signalWithStatus:kStatus2] data:@"data2"];
    XCTAssert(testRegister_signal1_and_signal2_fire_count == 2);
    
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] data:@"data1"];
    XCTAssert(testRegister_signal1_and_signal2_fire_count == 2);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal1 signalWithStatus:kStatus2] data:@"data2"];
    XCTAssert(testRegister_signal1_and_signal2_fire_count == 3);
}

- (void)testRegisterblockCancel
{
    __block NSInteger testRegister_signal_forever_fire_times = 0;
    [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterSignal signalDefault] block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2Signal) {
        testRegister_signal_forever_fire_times++;
        if (testRegister_signal_forever_fire_times == 2) {
            return NO;
        }
        return YES;
    }];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signalDefault] data:@"data"];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signalDefault] data:@"data"];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signalDefault] data:@"data"];
    XCTAssert(testRegister_signal_forever_fire_times == 2);
}


- (void)testHungUpList
{
    Bulb* bulb = [Bulb bulbWithName:@"testHungUpList"];
    [bulb hungUpAndFire:[BulbTestRegisterSignal signalDefault] data:@"data1"];
    
    BulbSignal* signal = [bulb getSignalFromHungUpList:[BulbTestRegisterSignal identifier]];
    XCTAssert(signal.status == kSignalOn);
    
    [bulb hungUp:[BulbTestRegisterSignal signalDefault].off data:nil];
    
    signal = [bulb getSignalFromHungUpList:[BulbTestRegisterSignal identifier]];
    XCTAssert(signal.status == kSignalOff);
}

- (void)testRecoverFromHungUp
{
    [[Bulb bulbGlobal] hungUp:[BulbTestRegisterSignal signalDefault] data:nil];
    __block id testRegister_init_from_hungUp = nil;
    BulbSlot* slot = [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterSignal signalDefault].recoverFromHungUp block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2Signal) {
        testRegister_init_from_hungUp = @"not null";
        return NO;
    }];
    BulbSignal* signal = slot.signals.firstObject;
    XCTAssert(signal != nil);
    XCTAssert(signal.status == kSignalOn);
    XCTAssert(testRegister_init_from_hungUp != nil);
    testRegister_init_from_hungUp = nil;
    
    
    // forever
    slot = [[Bulb bulbGlobal] registerSignals:@[[BulbTestRegisterSignal signalDefault].recoverFromHungUp, [BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1]] block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2Signal) {
        testRegister_init_from_hungUp = @"not null";
        if ([firstData isEqualToString:@"cancel"]) {
            return NO;
        }
        return YES;
    }];
    signal = slot.signals.firstObject;
    XCTAssert(signal != nil);
    XCTAssert(signal.status == kSignalOn);
    signal = slot.signals.lastObject;
    XCTAssert(signal != nil);
    XCTAssert(signal.status == kSignalOff);
    
    testRegister_init_from_hungUp = nil;
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] data:nil];
    XCTAssert(testRegister_init_from_hungUp != nil);
    testRegister_init_from_hungUp = nil;
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] data:nil];
    XCTAssert(testRegister_init_from_hungUp != nil);
    
    // pick off
    [[Bulb bulbGlobal] pickOff:[BulbTestRegisterSignal signalDefault]];
    testRegister_init_from_hungUp = nil;
    
    // not work because pick off
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] data:nil];
    XCTAssert(testRegister_init_from_hungUp == nil);
    
    // re fire can work again
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signalDefault] data:@"cancel"];
    XCTAssert(testRegister_init_from_hungUp != nil);
    
    // after pick off register is not work immediately
    testRegister_init_from_hungUp = nil;
    [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterSignal signalDefault].recoverFromHungUp block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2Signal) {
        testRegister_init_from_hungUp = @"not null";
        return NO;
    }];
    XCTAssert(testRegister_init_from_hungUp == nil);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signalDefault] data:nil];
    XCTAssert(testRegister_init_from_hungUp != nil);
    
    // muti signals
    testRegister_init_from_hungUp = nil;
    [[Bulb bulbGlobal] hungUp:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] data:nil];
    [[Bulb bulbGlobal] registerSignals:@[[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1].recoverFromHungUp, [BulbTestRegisterMutiStatusSignal1 signalWithStatus:kStatus1]] block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2Signal) {
        testRegister_init_from_hungUp = @"not null";
        return NO;
    }];
    XCTAssert(testRegister_init_from_hungUp == nil);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal1 signalWithStatus:kStatus1].recoverFromHungUp data:nil];
    XCTAssert(testRegister_init_from_hungUp != nil);
    
    // both hungup
    testRegister_init_from_hungUp = nil;
    [[Bulb bulbGlobal] hungUp:[BulbTestRegisterMutiStatusSignal1 signalWithStatus:kStatus1] data:nil];
    [[Bulb bulbGlobal] registerSignals:@[[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1].recoverFromHungUp, [BulbTestRegisterMutiStatusSignal1 signalWithStatus:kStatus1].recoverFromHungUp] block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2Signal) {
        testRegister_init_from_hungUp = @"not null";
        return YES;
    }];
    XCTAssert(testRegister_init_from_hungUp != nil);
    
    // pick off one, should not work
    testRegister_init_from_hungUp = nil;
    [[Bulb bulbGlobal] pickOff:[BulbTestRegisterMutiStatusSignal1 signalWithStatus:kStatus1]];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] data:nil];
    XCTAssert(testRegister_init_from_hungUp == nil);
}

- (void)testWeakDataWrapper
{
    [[Bulb bulbGlobal] registerSignals:@[[BulbTestRegisterSignal signalDefault], [BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1]] block:^BOOL(id firstData, NSDictionary<NSString *, BulbSignal *> *signalIdentifier2Signal) {
        NSLog(@"noti exe ! %@", firstData);
        XCTAssert(firstData == nil);
    }];
    
    @autoreleasepool {
        BulbTextDealloc* a = [[BulbTextDealloc alloc] init];
        [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signalDefault] data:[BulbWeakDataWrapper wrap:a]];
    }
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] data:@"data"];
}

- (void)testBulbNameEqual
{
    XCTAssert([Bulb bulbGlobal] == [Bulb bulbGlobal]);
    XCTAssert([Bulb bulbWithName:@"new_bulb_name"] == [Bulb bulbWithName:@"new_bulb_name"]);
}

- (void)testFilter
{
    __block id testRegister_signal_fire = nil;
    [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterSignal signalDefault] block:^BOOL(id firstData, NSDictionary<NSString *,id> *signalIdentifier2Signal) {
        testRegister_signal_fire = @"testRegister_signal_fire";
        NSLog(@"testRegister_signal data %@", firstData);
        return NO;
    } filterBlock:^BOOL(BulbSignal *signal) {
        if ([signal.data isEqualToString:@"data"]) {
            return YES;
        }
        return NO;
    }];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signalDefault] data:@"data"];
    XCTAssert(![testRegister_signal_fire isEqualToString:@"testRegister_signal_fire"]);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterSignal signalDefault] data:@"data1"];
    XCTAssert([testRegister_signal_fire isEqualToString:@"testRegister_signal_fire"]);
}

- (void)testRecorder
{
#ifdef BULB_RECORDER
    [BulbTestRegisterSignal signalDefault];
    [BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1];
    [BulbTestRegisterMutiStatusSignal1 signalWithStatus:kStatus2];
    
    NSString* allSignals = [[BulbRecorder sharedInstance] allSignals];
    NSLog(@"%@", allSignals);
    XCTAssert(allSignals != nil);
#endif
}

- (void)testOrigin
{
    __block NSInteger testRegister_signal_origin_status = -1;
    BulbSlot* slot = [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
        testRegister_signal_origin_status = [signalIdentifier2Signal objectForKey:[BulbTestRegisterMutiStatusSignal identifier]].originStatus;
        return NO;
    }];
    [slot updateSignal:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus2] data:nil];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] data:nil];
    XCTAssert(testRegister_signal_origin_status == kStatus2);
    
    testRegister_signal_origin_status = -1;
    [[Bulb bulbGlobal] registerSignal:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus3] block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
        if ([signalIdentifier2Signal objectForKey:[BulbTestRegisterMutiStatusSignal identifier]].originStatus == kStatus2) {
            testRegister_signal_origin_status = 23;
            XCTAssert([[signalIdentifier2Signal objectForKey:[BulbTestRegisterMutiStatusSignal identifier]].originData isEqualToString:@"data2"]);
            XCTAssert([[signalIdentifier2Signal objectForKey:[BulbTestRegisterMutiStatusSignal identifier]].data isEqualToString:@"data3"]);
        }
        return YES;
    }];
    
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus1] data:nil];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus3] data:nil];
    XCTAssert(testRegister_signal_origin_status == -1);
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus2] data:@"data2"];
    [[Bulb bulbGlobal] fire:[BulbTestRegisterMutiStatusSignal signalWithStatus:kStatus3] data:@"data3"];
    XCTAssert(testRegister_signal_origin_status == 23);
}

- (void)testSignalClassity
{
    __block id testSignal_classity = nil;
    Bulb* bulb = [Bulb bulbWithName:@"testSignalClassity"];
    [bulb registerSignals:@[[BulbTestRegisterSignal signalWithClassify:@"use1"], [BulbTestRegisterSignal signalWithClassify:@"use2"], [BulbTestRegisterSignal signalWithClassify:@"use3"]] block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
        testSignal_classity = @"3 users here";
        return NO;
    }];
    [bulb fire:[BulbTestRegisterSignal signalWithClassify:@"use1"] data:nil];
    XCTAssertNil(testSignal_classity);
    [bulb fire:[BulbTestRegisterSignal signalWithClassify:@"use2"] data:nil];
    XCTAssertNil(testSignal_classity);
    [bulb fire:[BulbTestRegisterSignal signalWithClassify:@"use3"] data:nil];
    XCTAssertNotNil(testSignal_classity);
    
}

@end
