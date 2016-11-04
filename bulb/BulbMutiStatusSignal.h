//
//  BulbMutiStatusSignal.h
//  bulb
//
//  Created by FanFamily on 2016/11/1.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import "BulbSignal.h"

@interface BulbMutiStatusSignal : BulbSignal

+ (instancetype)signalWithStatus:(NSString *)status;
+ (instancetype)signalWithStatus:(NSString *)status initFromSave:(BOOL)fromSave;

- (void)setStatus:(NSString *)status;

- (NSString *)status;

- (void)off;

@end
