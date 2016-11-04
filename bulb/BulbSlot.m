//
//  BulbSlot.m
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbSlot.h"
#import "Bulb.h"
#import "BulbWeakDataWrapper.h"

@interface BulbSlot ()

@property (nonatomic, assign) NSInteger fireCount;

@end

@implementation BulbSlot

- (instancetype)initWithSignals:(NSArray<BulbSignal *> *)signals block:(BulbBlock)block fireTable:(NSArray<NSDictionary<NSString *, NSString *>*>* )fireTable type:(BulbSignalSlotType)type
{
    self = [super init];
    if (self) {
        _signals = signals;
        _block = block;
        _fireTable = fireTable;
        _type = type;
    }
    return self;
}

- (void)fireSignal:(BulbSignal *)signal data:(id)data
{
    [self updateSignal:signal data:data];
    if ([self canBeFire] && self.block) {
        NSMutableDictionary* signalIdentifier2data = [NSMutableDictionary dictionary];
        __block id firstData = nil;
        __block BOOL firstDataFind = NO;
        [self.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id unwrapperData = [BulbWeakDataWrapper unwrapperData:obj.data];
            if (firstDataFind == NO) {
                firstDataFind = YES;
                firstData = unwrapperData;
            }
            if (unwrapperData) {
                [signalIdentifier2data setObject:unwrapperData forKey:[obj.class identifier]];
            }
        }];
        self.block(firstData, signalIdentifier2data);
        self.fireCount++;
    }
}

- (void)updateSignal:(BulbSignal *)newSignal data:(id)data
{
    BulbSignal* signal = [self hasSignal:[newSignal.class identifier]];
    if (!signal) {
        return ;
    }
    signal.status = newSignal.status;
    signal.data = data;
}

- (BulbSignal *)hasSignal:(NSString *)identifier
{
    __block BulbSignal* resultSignal = nil;
    [self.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[signal.class identifier] isEqualToString:identifier]) {
            resultSignal = signal;
            *stop = YES;
        }
    }];
    return resultSignal;
}

- (BOOL)canBeFire
{
    __block BOOL isCanBeFire = NO;
    [self.fireTable enumerateObjectsUsingBlock:^(NSDictionary<NSString *,NSString *> * _Nonnull identifier2status, NSUInteger idx, BOOL * _Nonnull stop) {
        __block NSInteger matchCount = 0;
        [self.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[identifier2status objectForKey:[signal.class identifier]] isEqualToString:signal.status]) {
                matchCount++;
            };
        }];
        /*!
         *  @brief 数组中有一项匹配就被认为可以fire
         */
        if (matchCount == self.signals.count) {
            isCanBeFire = YES;
            *stop = YES;
        }
    }];
    return isCanBeFire;
}

- (NSInteger)fireCount
{
    return _fireCount;
}

- (void)resetSignals
{
    for (BulbSignal* signal in self.signals) {
        [signal reset];
        // 如果状态槽, 存在信号状态不重置，赋予最后的状态
        if ([self.delegate respondsToSelector:@selector(bulbSlotInternalSignalRest:)]) {
            [self.delegate bulbSlotInternalSignalRest:signal];
        }
    }
    self.fireCount = 0;
}

@end
