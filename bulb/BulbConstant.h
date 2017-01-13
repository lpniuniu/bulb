//
//  BulbConstant.h
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BulbSignal;

typedef enum : NSInteger {
    kBulbSignalStatusNone = -2,
    kBulbSignalStatusOff = -1
} BulbSignalInternalStatus;

typedef BOOL(^BulbHasResultBlock)(id firstData, NSDictionary<NSString *, BulbSignal *>* signalIdentifier2Signal);

typedef BOOL(^BulbFilterBlock)(BulbSignal* signal);
