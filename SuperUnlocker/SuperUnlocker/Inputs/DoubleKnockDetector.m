//
//  MotionDetector.m
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 3/28/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "DoubleKnockDetector.h"

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <libextobjc/EXTScope.h>


static NSString * const lock = @"lock";


@interface DoubleKnockDetector ()

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, strong) NSMutableString *userAccelerometerLog;

@property (nonatomic) BOOL wasFirstKnock;
@property (nonatomic, strong) NSDate* firstKnockTime;
@property (nonatomic, copy) DoubleKnockHandler doubleKnockHandler;

@end


@implementation DoubleKnockDetector

- (instancetype)initWithDoubleKnockHandler:(DoubleKnockHandler)handler {
    self = [self init];
    if (self) {
        self.doubleKnockHandler = handler;
        self.motionManager = [[CMMotionManager alloc] init];
    }
    [self start];
    return self;
}

- (void)start {
    if (!self.motionManager.deviceMotionActive) {
        [self startUserAccelerometer];
    }
}

- (void)startUserAccelerometer {
    @weakify(self);
    [self.motionManager startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        @strongify(self);
        float zVal = fabs(motion.userAcceleration.z);
        BOOL wasKnock = NO;
        @synchronized(lock) {
            if(zVal > 0.5f){
                wasKnock = YES;
                NSTimeInterval deltaTime = 0.0;
                NSDate *currentDate = [NSDate date];
                if (self.firstKnockTime) {
                    deltaTime = [currentDate timeIntervalSinceDate:self.firstKnockTime];
                    NSLog(@"delta time %f", deltaTime);
                }
                if (0.1 < deltaTime && deltaTime < 0.2) {
                    NSLog(@"knock");
                    self.doubleKnockHandler();
                    self.wasFirstKnock = NO;
                } else {
                    self.firstKnockTime = currentDate;
                    self.wasFirstKnock = YES;
                }
            } else if (self.wasFirstKnock) {
                self.wasFirstKnock = NO;
            }
        }
        
        NSString *str = [NSString stringWithFormat:@"%f, %f, %f, %@", fabs(motion.userAcceleration.x), fabs(motion.userAcceleration.y), fabs(motion.userAcceleration.z), [NSDate date]];
        str = [str stringByReplacingOccurrencesOfString:@"." withString:@","];
//        if(wasKnock){
//            NSLog(@"Accell: %@", str);
//        }
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [self.userAccelerometerLog appendFormat:@"%@\n", str];
//        });

    }];
}

- (void)stop {
    [self.motionManager stopDeviceMotionUpdates];
}

- (void)dealloc {
    NSLog(@"deallocated motion manager");
}
@end
