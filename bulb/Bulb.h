//
//  bulb.h
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulbConstant.h"

@interface Bulb : NSObject

/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifier 信号唯一标识
 *  @param block            信号回调，信号fire只执行一次，如果需要再注册
 */
+ (void)regiseterSignal:(NSString *)signalIdentifier block:(BulbBlock)block;

/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifier 信号唯一标识
 *  @param status           信号激活的状态
 *  @param block            信号回调，信号fire只执行一次，如果需要再注册
 */
+ (void)regiseterSignal:(NSString *)signalIdentifier status:(NSString *)status block:(BulbBlock)block;

/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifiers 信号唯一标识组，全部fire触发回调
 *  @param block             信号回调，信号fire只执行一次，如果需要再注册
 */
+ (void)regiseterSignals:(NSArray *)signalIdentifiers block:(BulbBlock)block;

// TODO mac regiseter

/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifier 信号唯一标识
 *  @param foreverblock     信号回调, 回调保留，信号fire就执行
 */
+ (void)regiseterSignal:(NSArray *)signalIdentifier foreverblock:(BulbBlock)foreverblock;

/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifier 信号唯一标识
 *  @param status           信号激活的状态
 *  @param block            信号回调, 回调保留，信号fire就执行
 */
+ (void)regiseterSignal:(NSString *)signalIdentifier status:(NSString *)status foreverblock:(BulbBlock)foreverblock;

/*!
 *  @brief 注册信号
 *
 *  @param signalIdentifier 信号唯一标识
 *  @param foreverblock     信号回调, 回调保留，信号fire就执行
 */
+ (void)regiseterSignals:(NSArray *)signalIdentifiers foreverblock:(BulbBlock)foreverblock;

// TODO map regiseter

// Todo regiseterSignal 其他触发条件

/*!
 *  @brief 在信号发生后执行，如果已发送立即执行，否则延后执行
 */
+ (void)runAfterSignal:(NSString *)signalIdentifier block:(BulbBlock)block;
+ (void)runAfterSignal:(NSString *)signalIdentifier status:(NSString *)status block:(BulbBlock)block;
+ (void)runAfterSignals:(NSArray *)signalIdentifiers block:(BulbBlock)block;
+ (void)runAfterSignalsWithStatus:(NSDictionary *)signalIdentifier2status block:(BulbBlock)block;

/*!
 *  @brief 如果没有发送过传入信号，就执行，否则不执行
 */
+ (void)runNoSignal:(NSString *)signalIdentifier block:(void(^)())block;
+ (void)runNoSignals:(NSArray *)signalIdentifiers block:(void(^)())block;

/*!
 *  @brief 发出信号
 */
+ (void)fire:(NSString *)signalIdentifier data:(id)data;
+ (void)fire:(NSString *)signalIdentifier status:(NSString *)status data:(id)data;
+ (void)fireAndSave:(NSString *)signalIdentifier data:(id)data;
+ (void)fireAndSave:(NSString *)signalIdentifier status:(NSString *)status data:(id)data;

/**
 @brief 保存信号, 信号会记录下历史中，方便一些业务逻辑查看使用
 */
+ (void)save:(NSString *)signalIdentifier status:(NSString *)status data:(id)data;

/*!
 *  @brief 获取某信号的状态
 *
 *  @param signalIdentifier 信号唯一标识
 *
 *  @return 信号状态
 */
+ (NSString *)getSignalStatusFromHistory:(NSString *)signalIdentifier;

@end
