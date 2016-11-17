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


typedef NS_ENUM(NSUInteger, BulbSignalSlotFireType) {
    kBulbSignalSlotNotFired = 0,    // 槽未响应
    kBulbSignalSlotFiredResultYes,  // 槽被fire, 返回值yes
    kBulbSignalSlotFiredResultNo    // 槽被fire, 返回值no
};

/*!
 *  @brief 信号槽，容纳信号，当满足条件被fire，从队列中移除，并重新添加到队尾
 */
@interface BulbSlot : NSObject

- (instancetype)initWithSignals:(NSArray<BulbSignal *> *)signals block:(BulbHasResultBlock)block fireTable:(NSArray<NSDictionary<NSString *, NSString *>*>* )fireTable;

@property (nonatomic) NSArray<BulbSignal *>* signals;

/*!
 *  @brief 点亮查询表 NSDictionary<signalIdentifier, status>
 */
@property (nonatomic) NSArray<NSDictionary<NSString *, NSString *>*>* fireTable;

@property (nonatomic, copy) BulbHasResultBlock block;
@property (nonatomic, copy) BulbFilterBlock filterBlock;

/*!
 *  @brief 改变信号状态, 并fire
 *
 *  @param signal           信号对象
 */
- (BulbSignalSlotFireType)fireSignal:(BulbSignal *)signal data:(id)data;

/*!
 *  @brief 改变信号状态， 不fire
 *
 *  @param signal           信号对象
 */
- (void)updateSignal:(BulbSignal *)signal data:(id)data;

/*!
 *  @brief 是否存在某种信号
 *
 *  @param signal           信号对象
 *
 *  @return 找到的信号，没找到返回nil
 */
- (BulbSignal *)hasSignal:(BulbSignal *)signal;

/*!
 *  @brief 信号是否被过滤
 */
- (BOOL)isFiltered:(BulbSignal *)signal;

/*!
 *  @brief 判断内部信号状态是否可以激活
 *
 *  @return Yes block将会调用，NO block等待符合条件的时候调用
 */
- (BOOL)canBeFire;

/*!
 *  @brief fire 次数
 */
- (NSInteger)fireCount;

/*!
 *  @brief 重置信号为初始状态
 */
- (void)resetSignals;

/*!
 *  @brief 重置信号, 并保留origin数据，到下一个触发
 */
- (void)resetForeverSignals;

@end
