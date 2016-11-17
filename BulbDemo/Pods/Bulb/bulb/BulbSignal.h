//
//  BulbSignal.h
//  bulb
//
//  Created by FanFamily on 2016/11/1.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulbConstant.h"

@interface BulbSignal : NSObject

/*!
 *  @brief 信号唯一标识
 */
+ (NSString *)identifier;
- (NSString *)identifier;

@property (nonatomic, copy) NSString* status;
@property (nonatomic, copy) NSString* originStatus;
@property (nonatomic) id data;
@property (nonatomic) id originData;

/*!
 *  @brief YES:信号使用save list中保存的状态和数据
 */
@property (nonatomic, assign) BOOL recoverStatusFromSave;

- (void)reset;

@end
