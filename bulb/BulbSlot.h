//
//  BulbSlot.h
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulbSignal.h"
#import "BulbConstant.h"


@protocol BulbSlotDelegate <NSObject>

// 内部信号被重置
- (void)bulbSlotInternalSignalRest:(BulbSignal *)signal;

@end

/*!
 *  @brief 信号槽，容纳信号
 */
@interface BulbSlot : NSObject

- (instancetype)initWithSignals:(NSArray<BulbSignal *> *)signals block:(BulbBlock)block fireTable:(NSArray<NSDictionary<NSString *, NSString *>*>* )fireTable type:(BulbSignalSlotType)type;

@property (nonatomic) NSArray<BulbSignal *>* signals;
@property (weak, nonatomic) id<BulbSlotDelegate> delegate;

/*!
 *  @brief 点亮查询表 NSDictionary<signalIdentifier, status>
 */
@property (nonatomic) NSArray<NSDictionary<NSString *, NSString *>*>* fireTable;

@property (nonatomic, copy) BulbBlock block;

@property (nonatomic, assign) BulbSignalSlotType type; // 槽的类型

/*!
 *  @brief 改变信号状态, 并fire
 *
 *  @param signalIdentifier 信号
 *  @param status           信号状态
 */
- (void)fireSignal:(BulbSignal *)signal data:(id)data;

/*!
 *  @brief 改变信号状态， 不fire
 *
 *  @param signalIdentifier 信号
 *  @param status           信号状态
 */
- (void)updateSignal:(BulbSignal *)signal data:(id)data;

/*!
 *  @brief 是否存在某种信号
 *
 *  @param identifier 信号唯一标识
 *
 *  @return 找到的信号，没找到返回nil
 */
- (BulbSignal *)hasSignal:(NSString *)identifier;

/*!
 *  @brief 判断内部信号状态是否可以激活
 *
 *  @return Yes block将会调用，NO block等待符合条件的时候调用
 */
- (BOOL)canBeFire;

/*!
 *  @brief fire count
 */
- (NSInteger)fireCount;

/*!
 *  @brief reset
 */
- (void)resetSignals;

@end
