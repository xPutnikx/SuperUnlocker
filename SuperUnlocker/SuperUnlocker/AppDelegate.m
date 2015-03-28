//
//  AppDelegate.m
//  SuperUnlocker
//
//  Created by Vladimir Hudnitsky on 3/21/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "AppDelegate.h"
#import "MotionDetector.h"


@interface AppDelegate ()

@property (nonatomic, strong) MotionDetector *motionDetector;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.motionDetector = [[MotionDetector alloc] init];
    [self.motionDetector start];//test
    return YES;
}

@end
