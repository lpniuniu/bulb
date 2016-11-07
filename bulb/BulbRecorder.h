//
//  BulbRecorder.h
//  bulb
//
//  Created by FanFamily on 2016/11/7.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BulbRecorder : NSObject

+ (instancetype)sharedInstance;

- (NSString *)allSignals;

@end
