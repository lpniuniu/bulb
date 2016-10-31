//
//  bulb.h
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulbConstant.h"
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
- (void)registerSignal:(NSString *)signalIdentifier block:(BulbBlock)block;

/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifier 信号唯一标识
 *  @param status           信号激活的状态
 *  @param block            信号回调，信号fire只执行一次，如果需要再注册
 */
- (void)registerSignal:(NSString *)signalIdentifier status:(NSString *)status block:(BulbBlock)block;

/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifiers 信号唯一标识组，全部fire触发回调
 *  @param block             信号回调，信号fire只执行一次，如果需要再注册
 */
- (void)registerSignals:(NSArray *)signalIdentifiers block:(BulbBlock)block;

// TODO mac register

/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifier 信号唯一标识
 *  @param foreverblock     信号回调, 回调保留，信号fire就执行
 */
- (void)registerSignal:(NSString *)signalIdentifier foreverblock:(BulbBlock)foreverblock;

/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifier 信号唯一标识
 *  @param status           信号激活的状态
 *  @param block            信号回调, 回调保留，信号fire就执行
 */
- (void)registerSignal:(NSString *)signalIdentifier status:(NSString *)status foreverblock:(BulbBlock)foreverblock;

/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifier 信号唯一标识
 *  @param foreverblock     信号回调, 回调保留，信号fire就执行
 */
- (void)registerSignals:(NSArray *)signalIdentifiers foreverblock:(BulbBlock)foreverblock;

// TODO map register

// Todo registerSignal 其他触发条件

/*!
 *  @brief 如果save list中存在立即执行，否则registerSignal, 在未来触发时执行，执行一次
 */
- (void)registerSignalIfNotSave:(NSString *)signalIdentifier block:(BulbBlock)block;
- (void)registerSignalIfNotSave:(NSString *)signalIdentifier status:(NSString *)status block:(BulbBlock)block;
- (void)registerSignalsIfNotSave:(NSArray *)signalIdentifiers block:(BulbBlock)block;
- (void)registerSignalsIfNotSaveWithStatus:(NSDictionary *)signalIdentifier2status block:(BulbBlock)block;

/*!
 *  @brief 发出信号
 */
- (void)fire:(NSString *)signalIdentifier data:(id)data;
- (void)fire:(NSString *)signalIdentifier status:(NSString *)status data:(id)data;
- (void)fireAndSave:(NSString *)signalIdentifier data:(id)data;
- (void)fireAndSave:(NSString *)signalIdentifier status:(NSString *)status data:(id)data;

/**
 @brief 保存信号, 信号会记录下save list，方便一些业务逻辑查看使用
 */
- (void)save:(NSString *)signalIdentifier data:(id)data;
- (void)save:(NSString *)signalIdentifier status:(NSString *)status data:(id)data;

/*!
 *  @brief 获取某信号的状态
 *
 *  @param signalIdentifier 信号唯一标识
 *
 *  @return 信号状态
 */
- (NSString *)getSignalStatusFromSaveList:(NSString *)signalIdentifier;

@end
