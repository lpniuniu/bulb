//
//  BulbRecorder+Private.h
//  bulb
//
//  Created by FanFamily on 2016/11/7.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbRecorder.h"
#import "Bulb.h"
#import "BulbSignal.h"

@interface BulbRecorder (Private)

- (void)addSignalsRecord:(NSString *)record;
- (void)addSignalsRegisterRecord:(Bulb *)bulb signals:(NSArray<BulbSignal *> *)signals;
- (void)addSignalFireRecord:(Bulb *)bulb signal:(BulbSignal *)signal;

@end
