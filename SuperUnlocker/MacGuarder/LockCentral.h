//
//  LockCentral.h
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 4/1/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MacGuarder;


@interface LockCentral : NSObject

+ (instancetype)sharedInstance;
+ (void)setMacGuarder:(MacGuarder *)macGuarder;

- (void)start;
- (void)stop;

@end
