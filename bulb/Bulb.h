//
//  bulb.h
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulbConstant.h"
#import "BulbSignal.h"
#import "BulbBoolSignal.h"
#import "BulbMutiStatusSignal.h"
#import "BulbWeakDataWrapper.h"

@interface Bulb : NSObject

@property (nonatomic, copy) NSString* name;

+ (instancetype)bulbGlobal;
+ (instancetype)bulbWithName:(NSString *)name;

/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifier 信号唯一标识
 *  @param block            信号回调，信号fire只执行一次，如果需要再注册
 */
- (void)registerSignal:(BulbSignal *)signal block:(BulbBlock)block;

/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifiers 信号唯一标识组，全部fire触发回调
 *  @param block             信号回调，信号fire只执行一次，如果需要再注册
 */
- (void)registerSignals:(NSArray<BulbSignal *> *)signals block:(BulbBlock)block;

/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifier 信号唯一标识
 *  @param foreverblock     信号回调, 回调保留，信号fire就执行
 */
- (void)registerSignal:(BulbSignal *)signal foreverblock:(BulbBlock)foreverblock;


/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifier 信号唯一标识
 *  @param foreverblock     信号回调, 回调保留，信号fire就执行
 */
- (void)registerSignals:(NSArray<BulbSignal *> *)signals foreverblock:(BulbBlock)foreverblock;

/*!
 *  @brief 如果save list中存在立即执行，否则registerSignal, 在未来触发时执行，执行一次
 */
- (void)registerSignalIfNotSave:(BulbSignal *)signal block:(BulbBlock)block;
- (void)registerSignalsIfNotSave:(NSArray<BulbSignal *> *)signals block:(BulbBlock)block;

- (void)registerSignalIfNotSave:(BulbSignal *)signal foreverblock:(BulbBlock)block;
- (void)registerSignalsIfNotSave:(NSArray<BulbSignal *> *)signals foereverblock:(BulbBlock)block;


/*!
 *  @brief 发出信号
 */
- (void)fire:(BulbSignal *)signal data:(id)data;
- (void)fireAndSave:(BulbSignal *)signal data:(id)data;

/**
 @brief 保存信号, 信号会记录下save list，方便一些业务逻辑查看使用
 */
- (void)save:(BulbSignal *)signal data:(id)data;

/*!
 *  @brief 获取某信号的状态
 *
 *  @param signalIdentifier 信号唯一标识
 *
 *  @return 信号状态
 */
- (BulbSignal *)getSignalFromSaveList:(NSString *)signalIdentifier;

@end
