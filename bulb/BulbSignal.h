//
//  BulbSignal.h
//  bulb
//
//  Created by FanFamily on 2016/11/1.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulbConstant.h"

typedef enum : NSUInteger {
    kHungUpTypeNone,
    kHungUpTypeRecover, // 在slot形成和fire两个时刻，将恢复为挂灯上的状态
    kHungUpTypePickOff  // 在slot形成和fire两个时刻，将恢复为挂灯上的状态，并将挂灯移除
} HungUpType;

@interface BulbSignal : NSObject

/*!
 *  @brief 信号唯一标识
 */
+ (NSString *)identifier;
+ (NSString *)identifierWithClassify:(NSString *)classify;

- (NSString *)identifier; // 会出现带分类的细分identifier

@property (nonatomic, copy) NSString* identifierClassify; // 用于将子类型号细分，可以多次注册同一类信号

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) NSInteger originStatus;
@property (nonatomic) id data;
@property (nonatomic) id originData;

/*!
 *  @brief YES:信号使用hungUp list中保存的状态和数据
 */
@property (nonatomic, assign) HungUpType hungUpBehavior;

- (void)reset;

@end
