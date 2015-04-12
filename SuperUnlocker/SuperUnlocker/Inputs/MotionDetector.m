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


@interface MotionDetector ()

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, assign) MotionState motionState;

@property (nonatomic, strong) NSMutableString *accelerometerLog;
@property (nonatomic, strong) NSMutableString *gyroLog;
@property (nonatomic, strong) NSMutableString *userAccelerometerLog;
@property (nonatomic, strong) NSMutableString *actionLog;

@property (nonatomic) BOOL wasFirstKnock;
@property (nonatomic, strong) NSDate* firstKnockTime;
@property (nonatomic, copy) void (^motionHandler)();

@end


@implementation MotionDetector

+ (instancetype)sharedInstance {
    static MotionDetector *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MotionDetector alloc] init];
    });
    return instance;
}

- (instancetype) initWithMotionHandler: (void (^)()) motionHandler{
    self = [self init];
    if(self){
        self.motionHandler = motionHandler;
    }
    [self start];
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _motionState = MotionStateUnknown;
    }
    return self;
}

- (void)start {
    self.motionManager = [[CMMotionManager alloc] init];
    self.accelerometerLog = [[NSMutableString alloc] init];
    self.gyroLog = [[NSMutableString alloc] init];
    self.actionLog = [[NSMutableString alloc] init];

    [self startAccelerometer];
//    [self startGyro];
    [self startUserAccelerometer];
}

- (void)startAccelerometer {
    @weakify(self);
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        @strongify(self);
        NSString *str = [NSString stringWithFormat:@"%f, %f, %f, %@", fabs(accelerometerData.acceleration.x), fabs(accelerometerData.acceleration.y), fabs(accelerometerData.acceleration.z), [NSDate date]];
        str = [str stringByReplacingOccurrencesOfString:@"." withString:@","];
        dispatch_sync(dispatch_get_main_queue(), ^{
//            NSLog(@"Accell: %@", str);
            [self.accelerometerLog appendFormat:@"%@\n", str];
        });
    }];
}

- (void)startGyro {
    @weakify(self);
    [self.motionManager startGyroUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMGyroData *gyroData, NSError *error) {
        @strongify(self);
        NSString *str = [NSString stringWithFormat:@"%f, %f, %f, %@", gyroData.rotationRate.x, gyroData.rotationRate.y, gyroData.rotationRate.z, [NSDate date]];
        str = [str stringByReplacingOccurrencesOfString:@"." withString:@","];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.gyroLog appendFormat:@"%@\n", str];
        });
    }];

}

- (void)startUserAccelerometer {
    @weakify(self);
    [self.motionManager startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        @strongify(self);
        float zVal = fabs(motion.userAcceleration.z);
        float xVal = fabs(motion.userAcceleration.x);
        float yVal = fabs(motion.userAcceleration.y);
        BOOL wasKnock = NO;
        @synchronized(self.firstKnockTime){
        if(zVal > 0.5f){
            wasKnock = YES;
            NSTimeInterval deltaTime = 0.0;
            NSDate *currentDate = [NSDate date];
            if(self.firstKnockTime){
                deltaTime = [currentDate timeIntervalSinceDate:self.firstKnockTime];
                NSLog(@"delta time %f", deltaTime);
            }
            if(deltaTime > 0.1 && deltaTime < 0.2){
                NSLog(@"knock");
                self.motionHandler();
                self.wasFirstKnock = NO;
            }else{
                self.firstKnockTime = currentDate;
                self.wasFirstKnock = YES;
            }
        }else if(self.wasFirstKnock){
            self.wasFirstKnock = NO;
        }
        }
        
        NSString *str = [NSString stringWithFormat:@"%f, %f, %f, %@", fabs(motion.userAcceleration.x), fabs(motion.userAcceleration.y), fabs(motion.userAcceleration.z), [NSDate date]];
        str = [str stringByReplacingOccurrencesOfString:@"." withString:@","];
//        if(wasKnock){
//            NSLog(@"Accell: %@", str);
//        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.userAccelerometerLog appendFormat:@"%@\n", str];
        });

    }];
}

- (void)stop {
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopDeviceMotionUpdates];
    [self.motionManager stopGyroUpdates];
}

/*
 0 lock
 1 unlock
 2 no action
 3 start idle
 4 stop idle
 */

- (void)logLock {
    NSLog(@"lock");
    NSString *log = [NSString stringWithFormat:@"%d, %@", 0, [NSDate date]];
    [self.actionLog appendFormat:@"%@\n", log];
}

- (void)logUnLock {
    NSLog(@"unlock");
    NSString *log = [NSString stringWithFormat:@"%d, %@", 1, [NSDate date]];
    [self.actionLog appendFormat:@"%@\n", log];
}

- (void)logNoAction {
    NSLog(@"no action");
    NSString *log = [NSString stringWithFormat:@"%d, %@", 2, [NSDate date]];
    [self.actionLog appendFormat:@"%@\n", log];
}

- (void)logActions {
    NSString *log = self.actionLog;
    NSError *er;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSDate *date = [NSDate date];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%f_actions.txt", timeInterval];
    NSString *p = [documentsDirectory stringByAppendingPathComponent:fileName];
    [log writeToFile:p atomically:YES encoding:NSUTF8StringEncoding error:&er];
    if (!er) {
        NSLog(@"%@", er);
    }
}

- (void)startIdle {
    NSLog(@"start idle");
    NSString *log = [NSString stringWithFormat:@"%d, %@", 3, [NSDate date]];
    [self.actionLog appendFormat:@"%@\n", log];
    [self stop];
}

- (void)stopIdle {
    NSLog(@"stop idle");
    NSString *log = [NSString stringWithFormat:@"%d, %@", 4, [NSDate date]];
    [self.actionLog appendFormat:@"%@\n", log];
    [self start];
}

- (void)intermediateLog {
    NSLog(@"intermediate log");
    [self stop];
    [self start];
}

- (void)dealloc {
    NSLog(@"deallocated motion manager");
}
@end
