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
#import "BulbSlot.h"

@interface Bulb : NSObject

@property (nonatomic, copy) NSString* name;

+ (instancetype)bulbGlobal;
+ (instancetype)bulbWithName:(NSString *)name;

/*!
 *  @brief 注册信号
 *
 *  @param signal           信号对象, 内含目标状态
 *  @param block            信号回调，信号fire只执行一次，如果需要再注册
 */
- (BulbSlot *)registerSignal:(BulbSignal *)signal block:(BulbBlock)block;

/*!
 *  @brief 注册信号
 *
 *  @param signals           信号对象组，内含目标状态, 全部fire触发回调
 *  @param block             信号回调，信号fire只执行一次，如果需要再注册
 */
- (BulbSlot *)registerSignals:(NSArray<BulbSignal *> *)signals block:(BulbBlock)block;

/*!
 *  @brief 注册信号
 *
 *  @param signal           信号对象, 内含目标状态
 *  @param block            信号回调, 回调保留，信号fire就执行, foreverblock 中 return NO 可中断
 */
- (BulbSlot *)registerSignal:(BulbSignal *)signal foreverblock:(BulbHasResultBlock)foreverblock;


/*!
 *  @brief 注册信号
 *
 *  @param signals           信号对象组，内含目标状态, 全部fire触发回调
 *  @param block             信号回调, 回调保留，信号fire就执行, foreverblock 中 return NO 可中断
 */
- (BulbSlot *)registerSignals:(NSArray<BulbSignal *> *)signals foreverblock:(BulbHasResultBlock)foreverblock;

/*!
 *  @brief 过滤器系列接口
 *
 */
- (BulbSlot *)registerSignal:(BulbSignal *)signal block:(BulbBlock)block filterBlock:(BulbFilterBlock)filterBlock;
- (BulbSlot *)registerSignals:(NSArray<BulbSignal *> *)signals block:(BulbBlock)block filterBlock:(BulbFilterBlock)filterBlock;
- (BulbSlot *)registerSignal:(BulbSignal *)signal foreverblock:(BulbHasResultBlock)foreverblock filterBlock:(BulbFilterBlock)filterBlock;
- (BulbSlot *)registerSignals:(NSArray<BulbSignal *> *)signals foreverblock:(BulbHasResultBlock)foreverblock filterBlock:(BulbFilterBlock)filterBlock;

/*!
 *  @brief 发出信号
 */
- (void)fire:(BulbSignal *)signal data:(id)data;
- (void)fireAndSave:(BulbSignal *)signal data:(id)data;

/**
 @brief 保存信号, 信号会记录下save list，方便一些业务逻辑查看使用
 */
- (void)save:(BulbSignal *)signal data:(id)data;

/**
 @brief 从save list中移除信号
 */
- (void)remove:(BulbSignal *)signal;

/*!
 *  @brief 获取某信号的状态
 *
 *  @param signalIdentifier 信号唯一标识
 *
 *  @return 信号状态
 */
- (BulbSignal *)getSignalFromSaveList:(NSString *)signalIdentifier;

/*!
 *  @brief save list description
 */
- (NSString *)saveListDescription;

@end
