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
#import <libextobjc/EXTScope.h>

static NSInteger const MaxSteps = 4;
static float const ZeroAcceleration = 0.05;


@interface MotionDetector ()

@property (nonatomic, strong) CMMotionActivityManager *activityManager;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CMPedometer *pedometer;

@property (nonatomic, assign) MotionState motionState;

@property (nonatomic, strong) NSDate *lastStationeryDate;
@property (nonatomic, strong) NSDate *lastAccelerometerDate;

@end


@implementation MotionDetector

- (instancetype)init {
    self = [super init];
    if (self) {
        self.activityManager = [[CMMotionActivityManager alloc] init];
        self.pedometer = [[CMPedometer alloc] init];
        _motionState = MotionStateUnknown;
        self.motionManager = [[CMMotionManager alloc] init];
    }
    return self;
}

- (void)start {
    [self startPedometerUpdates];
    
    @weakify(self);
    self.lastAccelerometerDate = [NSDate date];
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        @strongify(self);
        NSTimeInterval realDifference = [[NSDate date] timeIntervalSinceDate:self.lastAccelerometerDate];
        if (realDifference < 1) {
            return;
        }
        self.lastAccelerometerDate = [NSDate date];
        
        NSInteger zeroCount = 0;
        if (fabs(accelerometerData.acceleration.x) < ZeroAcceleration) {
            zeroCount++;
        }
        if (fabs(accelerometerData.acceleration.y) < ZeroAcceleration) {
            zeroCount++;
        }
        if (fabs(accelerometerData.acceleration.z) < ZeroAcceleration) {
            zeroCount++;
        }
        if (zeroCount >= 2) {
            self.motionState = MotionStateStationary;
        }
    }];
}

- (void)setMotionState:(MotionState)motionState {
    _motionState = motionState;
    switch (motionState) {
        case MotionStateStationary: {
            NSLog(@"Stationary");
            [self.pedometer stopPedometerUpdates];
            self.lastStationeryDate = [NSDate date];
            [self startPedometerUpdates];
            break;
        }
        case MotionStateWalked: {
            NSLog(@"walked");
            break;
        }
        default:
            break;
    }
}

- (void)startPedometerUpdates {
    if ([CMPedometer isStepCountingAvailable]) {
        NSDate *startDate = self.lastStationeryDate ? self.lastStationeryDate : [NSDate date];
        @weakify(self);
        [self.pedometer startPedometerUpdatesFromDate:startDate withHandler:^(CMPedometerData *pedometerData, NSError *error) {
            @strongify(self);
            NSLog(@"steps: %ld", (long)pedometerData.numberOfSteps.integerValue);
            if (pedometerData.numberOfSteps.integerValue >= MaxSteps) {
                self.motionState = MotionStateWalked;
            }
        }];
    } else {
        NSLog(@"can't count steps");
    }
}

@end
