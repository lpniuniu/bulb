//
//  BulbConstant.h
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BulbSignal;

typedef void(^BulbBlock)(id firstData, NSDictionary<NSString *, BulbSignal *>* signalIdentifier2Signal);
typedef BOOL(^BulbHasResultBlock)(id firstData, NSDictionary<NSString *, BulbSignal *>* signalIdentifier2Signal);

typedef BOOL(^BulbFilterBlock)(BulbSignal* signal);
