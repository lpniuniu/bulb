//
//  BulbSignal.h
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 *  @brief 信号
 */
@interface BulbSignal : NSObject

- (instancetype)initWithSignalIdentifier:(NSString *)identifier;

@property (nonatomic, copy, readonly) NSString* identifier;
@property (nonatomic, copy) NSString* status; // 默认 kBulbSignalStatusOff
@property (nonatomic) id data;

- (void)reset;

@end
