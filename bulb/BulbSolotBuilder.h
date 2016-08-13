//
//  BulbRegister.h
//  bulb
//
//  Created by FanFamily on 16/8/12.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulbSlot.h"
#import "BulbSignal.h"

/*!
 *  @brief 注册信号，填充槽
 */
@interface BulbSolotBuilder : NSObject

+ (BulbSlot *)buildWithSignalsIdentifier:(NSArray *)signalIdentifiers block:(BulbBlock)block type:(BulbSignalSlotType)type;
+ (BulbSlot *)buildWithSignalsIdentifierMap:(NSDictionary *)signalIdentifier2status block:(BulbBlock)block type:(BulbSignalSlotType)type;

@end
