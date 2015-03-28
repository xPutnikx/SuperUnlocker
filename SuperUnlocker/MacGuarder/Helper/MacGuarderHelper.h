//
//  MacGuarderHelper.h
//  MacGuarder
//
//  Created by user on 14-7-23.
//  Copyright (c) 2014年 TrendMicro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LockManagerDelegate.h"
@protocol LockManagerDelegate;
@class GuarderUserDefaults;


@interface MacGuarderHelper : NSObject

- (instancetype)initWithSettings:(GuarderUserDefaults *)aSettings;
- (BOOL)isScreenLocked;                     // check if Mac is locked

- (void)lock;                               // lock the Mac
- (void)unlock;                             // unlock the Mac

- (void)setPassword:(NSString*)password;    // set Mac password

@property (nonatomic) id<LockManagerDelegate> lockDelegate;
@property (nonatomic, weak) GuarderUserDefaults *userSettings;
@property (nonatomic, strong) NSString *password;


@end
