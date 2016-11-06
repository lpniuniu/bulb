//
//  BulbConstant.h
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kBulbSignalStatusOff;
extern NSString* const kBulbSignalStatusOn;

typedef void(^BulbBlock)(id firstData, NSDictionary<NSString *, id>* signalIdentifier2data);
typedef BOOL(^BulbHasResultBlock)(id firstData, NSDictionary<NSString *, id>* signalIdentifier2data);
