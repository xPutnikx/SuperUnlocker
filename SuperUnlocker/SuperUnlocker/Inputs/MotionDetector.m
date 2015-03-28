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
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CMPedometer *pedometer;

@property (nonatomic, assign) UIBackgroundTaskIdentifier motionTaskId;

@property (nonatomic, assign, getter=isStationaryState) BOOL stationaryState;

@end


@implementation MotionDetector

- (instancetype)init {
    self = [super init];
    if (self) {
        self.activityManager = [[CMMotionActivityManager alloc] init];
        self.pedometer = [[CMPedometer alloc] init];
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.deviceMotionUpdateInterval = 1/10;
    }
    return self;
}

- (void)start {
    if ([CMMotionActivityManager isActivityAvailable]) {
        [self.activityManager startActivityUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMMotionActivity *activity) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.stationaryState = activity.stationary;
            });
        }];

    } else {
        NSLog(@"can't track activity on current device");
    }
    
    if ([CMPedometer isStepCountingAvailable]) {
        [self.pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"number of steps since date %@ %@ %@", pedometerData.numberOfSteps, pedometerData.startDate, pedometerData.endDate);
            });
        }];
    } else {
        NSLog(@"can't count steps");
    }
    
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        NSLog(@"%f %f %f", accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z);
    }];
}

@end
