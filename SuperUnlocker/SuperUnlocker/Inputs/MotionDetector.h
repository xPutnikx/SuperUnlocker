//
//  MotionDetector.h
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 3/28/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MotionState) {
    MotionStateUnknown,
    MotionStateWalked,
    MotionStateStationary
};


@interface MotionDetector : NSObject

+ (instancetype)sharedInstance;

- (void)start;
- (void)stop;
- (MotionState)motionState;

- (void)log;
- (void)intermediateLog;
- (void)logLock;
- (void)logUnLock;
- (void)logNoAction;
- (void)startIdle;
- (void)stopIdle;

@end
