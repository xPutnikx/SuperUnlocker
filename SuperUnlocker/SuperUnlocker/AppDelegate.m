//
//  AppDelegate.m
//  SuperUnlocker
//
//  Created by Vladimir Hudnitsky on 3/21/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "AppDelegate.h"
#import "MotionDetector.h"
#import "Peripheral.h"


@interface AppDelegate ()

@property (nonatomic, strong) MotionDetector *motionDetector;
@property (nonatomic, assign) UIBackgroundTaskIdentifier taskId;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.motionDetector = [[MotionDetector alloc] init];
    [self.motionDetector start];//test
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"will terminate");
    [[Peripheral sharedInstance] disconnect];
//    UIBackgroundTaskIdentifier taskId = [application beginBackgroundTaskWithExpirationHandler:^{
//        [[Peripheral sharedInstance] disconnect];
//        [application endBackgroundTask:taskId];
//    }];
}

@end
