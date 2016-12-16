//
//  BulbRecorder.m
//  bulb
//
//  Created by FanFamily on 2016/11/7.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbRecorder.h"
#import "Bulb.h"
#import "BulbSignal.h"

@interface BulbRecorder ()

@property (nonatomic) NSMutableArray<NSString *>* signalsRecord;
@property (nonatomic) NSMutableArray<NSString *>* signalsRegisterRecord;
@property (nonatomic) NSMutableArray<NSString *>* signalsFireRecord;
@property (nonatomic) NSMutableArray<NSString *>* signalsRecordHistory;
@property (nonatomic) dispatch_queue_t bulbRecorderDispatchQueue;

@end

@implementation BulbRecorder

+ (instancetype)sharedInstance
{
#ifdef BULB_RECORDER
    static BulbRecorder* recorder = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        recorder = [[BulbRecorder alloc] init];
        recorder.signalsRecord = [NSMutableArray array];
        recorder.signalsRecordHistory = [NSMutableArray array];
        recorder.signalsRegisterRecord = [NSMutableArray array];
        recorder.signalsFireRecord = [NSMutableArray array];
    });
    return recorder;
#else
    return nil;
#endif
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bulbRecorderDispatchQueue = dispatch_queue_create("bulbRecorderDispatchQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)addSignalsRecord:(NSString *)record
{
    dispatch_sync(self.bulbRecorderDispatchQueue, ^{
        [self.signalsRecord addObject:record];
    });
}

- (void)addSignalsRegisterRecord:(Bulb *)bulb signals:(NSArray<BulbSignal *> *)signals
{
    NSArray* callStack = [[NSThread callStackSymbols] subarrayWithRange:NSMakeRange(2, 7)];
    dispatch_sync(self.bulbRecorderDispatchQueue, ^{
        NSString* result = [NSString stringWithFormat:@"Bulb [%@] [R] ", bulb.name];
        for (id signal in signals) {
            result = [result stringByAppendingString:[signal description]];
        }
        // record call stack 5
        result = [result stringByAppendingString:[NSString stringWithFormat:@", call stack %@", callStack]];
        [self.signalsRegisterRecord addObject:result];
        [self.signalsRecordHistory addObject:result];
        NSLog(@"%@", result);
    });
}

- (void)addSignalFireRecord:(Bulb *)bulb signal:(BulbSignal *)signal
{
    NSArray* callStack = [[NSThread callStackSymbols] subarrayWithRange:NSMakeRange(2, 7)];
    dispatch_sync(self.bulbRecorderDispatchQueue, ^{
        NSString* result = [NSString stringWithFormat:@"Bulb [%@] [F] %@", bulb.name, signal];
        // record call stack 5
        result = [result stringByAppendingString:[NSString stringWithFormat:@", call stack %@", callStack]];
        [self.signalsFireRecord addObject:result];
        [self.signalsRecordHistory addObject:result];
        NSLog(@"%@", result);
    });
}

- (NSString *)allSignalsRegister
{
    __block NSString* result = @"\n----------------- 该app注册信号的历史记录 -----------------\n";
    [self.signalsRegisterRecord enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        result = [result stringByAppendingString:@"| "];
        result = [result stringByAppendingString:obj];
        result = [result stringByAppendingString:@"\n"];
    }];
    result = [result stringByAppendingString:@"\n"];
    result = [result stringByAppendingString:@"-------------------------------------------------------\n"];
    return result;
}

- (NSString *)allSignalsFire
{
    __block NSString* result = @"\n----------------- 该app fire 信号的历史记录 -----------------\n";
    [self.signalsFireRecord enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        result = [result stringByAppendingString:@"| "];
        result = [result stringByAppendingString:obj];
        result = [result stringByAppendingString:@"\n"];
    }];
    result = [result stringByAppendingString:@"\n"];
    result = [result stringByAppendingString:@"-------------------------------------------------------\n"];
    return result;
}

- (NSString *)allSignals
{
    __block NSString* result = @"\n----------------- 该app定义的所有信号列表 -----------------\n";
    [self.signalsRecord enumerateObjectsUsingBlock:^(NSString * _Nonnull signalRecord, NSUInteger idx, BOOL * _Nonnull stop) {
        result = [result stringByAppendingString:@"| "];
        result = [result stringByAppendingString:signalRecord];
        result = [result stringByAppendingString:@"\n"];
    }];
    result = [result stringByAppendingString:@"| "];
    result = [result stringByAppendingString:[NSString stringWithFormat:@"All signals count %lu", (unsigned long)self.signalsRecord.count]];
    result = [result stringByAppendingString:@"\n"];
    result = [result stringByAppendingString:@"====== 信号发生列表 =====\n"];
    [self.signalsRecordHistory enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        result = [result stringByAppendingString:@"| "];
        result = [result stringByAppendingString:obj];
        result = [result stringByAppendingString:@"\n"];
    }];
    result = [result stringByAppendingString:@"=====================\n"];
    result = [result stringByAppendingString:@"-------------------------------------------------------\n"];
    return result;
}

@end
