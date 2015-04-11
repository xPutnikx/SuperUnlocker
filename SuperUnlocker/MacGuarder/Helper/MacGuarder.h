//
//  MacGuarderHelper.h
//  MacGuarder
//
//  Created by user on 14-7-23.
//  Copyright (c) 2014年 TrendMicro. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LockManagerDelegate;
@class GuarderUserDefaults;


@interface MacGuarder : NSObject

- (instancetype)initWithSettings:(GuarderUserDefaults *)aSettings;
- (BOOL)isScreenLocked;                     // check if Mac is locked

- (void)lock;                               // lock the Mac
- (void)unlock;                             // unlock the Macu


@property (nonatomic, strong) GuarderUserDefaults *userSettings;

@end
