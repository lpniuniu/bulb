//
//  BulbWeakData.h
//  bulb
//
//  Created by FanFamily on 2016/10/27.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BulbWeakDataWrapper : NSObject

+ (id)wrap:(id)data;
+ (id)unwrapperData:(id)origindata;

@property (nonatomic, weak) id internalData;

@end
