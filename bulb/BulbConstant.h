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

typedef NS_ENUM(NSUInteger, BulbSignalSlotType) {
    kBulbSignalSlotTypeInstant = 0, // 瞬时槽, fire后消失
    kBulbSignalSlotTypeReAppend = 1,// 永久槽, fire后消失，添加到队列的最后面
};

typedef void(^BulbBlock)(id data, NSMapTable<NSString *, id>* fireDataTable);
