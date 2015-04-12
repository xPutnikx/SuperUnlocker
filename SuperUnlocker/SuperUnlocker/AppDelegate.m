//
//  AppDelegate.m
//  SuperUnlocker
//
//  Created by Vladimir Hudnitsky on 3/21/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "AppDelegate.h"
#import "KeyPeripheral.h"
#import "MotionDetector.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[MotionDetector sharedInstance] start];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[KeyPeripheral sharedInstance] disconnect];
}

@end
