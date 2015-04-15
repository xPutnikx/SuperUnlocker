//
//  AppDelegate.m
//  SuperUnlocker
//
//  Created by Vladimir Hudnitsky on 3/21/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "AppDelegate.h"
#import "KeyPeripheral.h"
#import "DoubleKnockDetector.h"

@interface AppDelegate ()

@property (nonatomic, strong) DoubleKnockDetector *motionDetector;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.motionDetector = [[DoubleKnockDetector alloc] initWithDoubleKnockHandler:^(void) {
        [[KeyPeripheral sharedInstance] lock];
    }];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[KeyPeripheral sharedInstance] disconnect];
}

@end
