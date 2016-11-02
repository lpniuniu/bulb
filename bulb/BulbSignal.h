//
//  BulbSignal.h
//  bulb
//
//  Created by FanFamily on 2016/11/1.
//  Copyright © 2016年 niuniu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulbConstant.h"

@interface BulbSignal : NSObject

+ (NSString *)identifier;

@property (nonatomic, copy) NSString* status;
@property (nonatomic) id data;

- (void)reset;

@end
