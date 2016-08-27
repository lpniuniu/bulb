//
//  BulbSlot.m
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbSlot.h"
#import "Bulb.h"

@interface BulbSlot ()

@property (nonatomic, assign) NSInteger fireCount;

@end

@implementation BulbSlot

- (instancetype)initWithSignals:(NSSet *)signals block:(BulbBlock)block fireTable:(NSArray<NSDictionary<NSString *, NSString *>*>* )fireTable type:(BulbSignalSlotType)type
{
    self = [super init];
    if (self) {
        _signals = signals;
        _block = block;
        _fireTable = fireTable;
        _type = type;
        _fireDataTable = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fireDataTable = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)fireStatusWithSignalIdentifier:(NSString *)signalIdentifier status:(NSString *)status data:(id)data
{
    [self updateStatusWithSignalIdentifier:signalIdentifier status:status data:data];
    if ([self canBeFire] && self.block) {
        self.block(self.fireDataTable.allValues.firstObject, self.fireDataTable);
        self.fireCount++;
    }
}

- (void)updateStatusWithSignalIdentifier:(NSString *)signalIdentifier status:(NSString *)status data:(id)data
{
    BulbSignal* siganl = [self hasSignal:signalIdentifier];
    if (!siganl) {
        return ;
    }
    siganl.status = status;
    siganl.data = data;
    if (data) {
        [self.fireDataTable setObject:data forKey:signalIdentifier];
    }
}

- (BulbSignal *)hasSignal:(NSString *)identifier
{
    __block BulbSignal* resultSignal = nil;
    [self.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, BOOL * _Nonnull stop) {
        if ([signal.identifier isEqualToString:identifier]) {
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
        [self.signals enumerateObjectsUsingBlock:^(BulbSignal * _Nonnull signal, BOOL * _Nonnull stop) {
            if ([[identifier2status objectForKey:signal.identifier] isEqualToString:signal.status]) {
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
        // 如果状态槽存在信号状态不重置，赋予最后的状态
        NSString* status = [Bulb getSignalStatusFromHistory:signal.identifier];
        if (status) {
            signal.status = status;
        }
    }
    self.fireCount = 0;
}

@end
