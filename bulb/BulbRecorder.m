//
//  BulbRecorder.m
//  bulb
//
//  Created by FanFamily on 2016/11/7.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbRecorder.h"

@interface BulbRecorder ()

@property (nonatomic) NSMutableArray<NSString *>* signalsRecord;

@end

@implementation BulbRecorder

+ (instancetype)sharedInstance
{
    static BulbRecorder* recorder = nil;
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        recorder = [[BulbRecorder alloc] init];
        recorder.signalsRecord = [NSMutableArray array];
    });
    return recorder;
}

- (void)addSignalsRecord:(NSString *)record
{
    [self.signalsRecord addObject:record];
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
    result = [result stringByAppendingString:[NSString stringWithFormat:@"All signals count %ld", self.signalsRecord.count]];
    result = [result stringByAppendingString:@"\n"];
    result = [result stringByAppendingString:@"-------------------------------------------------------\n"];
    return result;
}

@end
