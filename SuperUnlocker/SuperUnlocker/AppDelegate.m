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

@interface AppDelegate ()

@property (nonatomic, strong) MotionDetector *motionDetector;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.motionDetector = [[MotionDetector alloc] initWithMotionHandler:^(void) {
        [[KeyPeripheral sharedInstance] lock];
    }];
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[KeyPeripheral sharedInstance] disconnect];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake)
    {
        // User was shaking the device. Post a notification named "shake."
        NSLog(@"shake");
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
    }
}

@end
