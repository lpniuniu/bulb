//
//  BulbRecorder.h
//  bulb
//
//  Created by FanFamily on 2016/11/7.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief 跟踪记录信号，需预定义BULB_RECORDER宏才记录
 */
@interface BulbRecorder : NSObject

+ (instancetype)sharedInstance;

/*!
 *  @brief 返回信号全局定义表，以及register和fire的历史记录表
 */
- (NSString *)allSignals;

/*!
 *  @brief 返回register历史记录表
 */
- (NSString *)allSignalsRegister;

/*!
 *  @brief 返回fire历史记录表
 */
- (NSString *)allSignalsFire;

@end
