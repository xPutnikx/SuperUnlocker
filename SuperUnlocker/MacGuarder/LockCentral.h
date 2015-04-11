//
//  LockCentral.h
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 4/1/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^LockCommandHandler)();
typedef void (^UnlockCommandHandler)();
typedef BOOL (^ShouldConnectDeviceHandler)(NSString *name);


@interface LockCentral : NSObject

@property (nonatomic, copy) LockCommandHandler lockCommandHandler;
@property (nonatomic, copy) UnlockCommandHandler unlockCommandHandler;
@property (nonatomic, copy) ShouldConnectDeviceHandler shouldConnectDeviceHandler;

+ (instancetype)sharedInstance;

- (void)start;
- (void)stop;

@end
