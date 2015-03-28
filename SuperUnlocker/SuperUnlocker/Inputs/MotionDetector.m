//
//  MotionDetector.m
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 3/28/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "MotionDetector.h"

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>


@interface MotionDetector ()

@property (nonatomic, strong) CMMotionActivityManager *activityManager;
@property (nonatomic, assign) UIBackgroundTaskIdentifier motionTaskId;

@end


@implementation MotionDetector

- (instancetype)init {
    self = [super init];
    if (self) {
        self.activityManager = [[CMMotionActivityManager alloc] init];
    }
    return self;
}

- (void)start {
    if ([CMMotionActivityManager isActivityAvailable]) {
        [self.activityManager startActivityUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMMotionActivity *activity) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"some activity. is it active? %@", activity.stationary ? @"No" : @"Yes");
            });
        }];
    } else {
        NSLog(@"can't track activity on current device");
    }
}

@end
