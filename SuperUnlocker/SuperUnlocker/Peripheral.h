//
//  Peripheral.h
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 3/28/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Peripheral : NSObject

@property (nonatomic, assign) BOOL shouldLockMac;
@property (nonatomic, assign, getter = isOnPower) BOOL onPower;

+ (instancetype)sharedInstance;
- (void)disconnect;

@end
