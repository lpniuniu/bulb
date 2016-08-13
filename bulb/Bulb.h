//
//  bulb.h
//  bulb
//
//  Created by FanFamily on 16/8/11.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulbConstant.h"

@interface Bulb : NSObject

+ (void)regiseterSignal:(NSString *)signalIdentifier block:(BulbBlock)block;
+ (void)regiseterSignals:(NSArray *)signalIdentifiers block:(BulbBlock)block;
+ (void)regiseterSignal:(NSArray *)signalIdentifier foreverblock:(BulbBlock)foreverblock;
+ (void)regiseterSignals:(NSArray *)signalIdentifiers foreverblock:(BulbBlock)foreverblock;

+ (void)runAfterSignal:(NSString *)signalIdentifier block:(BulbBlock)block;
+ (void)runAfterSignals:(NSArray *)signalIdentifiers block:(BulbBlock)block;

+ (void)fire:(NSString *)signalIdentifier data:(id)data;

@end
