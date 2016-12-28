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

- (instancetype)initWithSignals:(NSArray<BulbSignal *> *)signals block:(BulbHasResultBlock)block fireTable:(NSArray<NSDictionary<NSString *, NSString *>*>* )fireTable
{
    self = [super init];
    if (self) {
        _signals = signals;
        _block = block;
        _fireTable = fireTable;
    }
    return self;
}

- (BulbSignalSlotFireType)fireSignal:(BulbSignal *)signal data:(id)data
{
    [self updateSignal:signal data:data];
    if ([self canBeFire]) {
        NSMutableDictionary* signalIdentifier2Signal = [NSMutableDictionary dictionary];
        __block id firstData = nil;
        __block BOOL firstDataFind = NO;
        [self.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
            id unwrapperData = [BulbWeakDataWrapper unwrapperData:signal.data];
            if (firstDataFind == NO) {
                firstDataFind = YES;
                firstData = unwrapperData;
            }
            // 创建新信号给外部，不影响内部信号
            BulbSignal* outSignal = [BulbBoolSignal signalDefault];
            outSignal.status = signal.status;
            outSignal.originStatus = signal.originStatus;
            outSignal.data =  unwrapperData;
            outSignal.originData = signal.originData;
            [signalIdentifier2Signal setObject:outSignal forKey:[signal identifier]];
        }];
        BulbSignalSlotFireType fireType = kBulbSignalSlotFiredResultNo;
        if (self.block) {
            if (self.block(firstData, signalIdentifier2Signal)) {
                fireType = kBulbSignalSlotFiredResultYes;
            }
        }
        self.fireCount++;
        return fireType;
    } else {
        return kBulbSignalSlotNotFired;
    }
}

- (void)updateSignal:(BulbSignal *)newSignal data:(id)data
{
    BulbSignal* signal = [self hasSignal:newSignal];
    if (!signal) {
        return ;
    }
    signal.status = newSignal.status;
    signal.data = data;
}

- (BulbSignal *)hasSignal:(BulbSignal *)firedSignal
{
    __block BulbSignal* resultSignal = nil;
    [self.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[firedSignal identifier] isEqualToString:signal.identifier]) {
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
            if ([identifier2status objectForKey:[signal identifier]].integerValue == signal.status) {
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

- (void)resetForeverSignals
{
    for (BulbSignal* signal in self.signals) {
        NSInteger originStatus = signal.status;
        id originData = signal.data;
        [signal reset];
        signal.originStatus = originStatus;
        signal.originData = originData;
    }
    self.fireCount = 0;
}

- (void)resetSignals
{
    for (BulbSignal* signal in self.signals) {
        [signal reset];
    }
    self.fireCount = 0;
}

- (BOOL)isFiltered:(BulbSignal *)signal
{
    if (self.filterBlock) {
        if (self.filterBlock(signal)) {
            return YES;
        }
    }
    return NO;
}

@end
