//
//  BulbOnceSlot.h
//  bulb
//
//  Created by FanFamily on 2016/11/6.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbSlot.h"

@interface BulbOnceSlot : BulbSlot

- (instancetype)initWithSignals:(NSArray<BulbSignal *> *)signals block:(BulbBlock)block fireTable:(NSArray<NSDictionary<NSString *, NSString *>*>* )fireTable;

@end
