//
//  BulbWeakData.h
//  bulb
//
//  Created by FanFamily on 2016/10/27.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief fire data 防止强引用，可用此类包裹后再传入
 */
@interface BulbWeakDataWrapper : NSObject

+ (id)wrap:(id)data;
+ (id)unwrapperData:(id)origindata;

@property (nonatomic, weak) id internalData;

@end
