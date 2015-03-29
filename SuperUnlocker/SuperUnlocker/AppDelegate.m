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


static NSString * const MotionDetectorStatePath = @"motionState";


@interface AppDelegate ()

@property (nonatomic, strong) MotionDetector *motionDetector;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    self.motionDetector = [[MotionDetector alloc] init];
//    [self.motionDetector start];
//    [self.motionDetector addObserver:self forKeyPath:MotionDetectorStatePath options:NSKeyValueObservingOptionNew context:nil];
    return YES;
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if ([keyPath isEqualToString:MotionDetectorStatePath]) {
//        MotionState motionState = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
//        switch (motionState) {
//            case MotionStateUnknown: {
//                NSLog(@"unknown");
//                break;
//            }
//            case MotionStateStationary: {
//                [Peripheral sharedInstance].shouldLockMac = NO;
//                break;
//            }
//            case MotionStateWalked: {
//                [Peripheral sharedInstance].shouldLockMac = YES;
//                break;
//            }
//        }
//    }
//}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"will terminate");
    [[Peripheral sharedInstance] disconnect];
    [self.motionDetector removeObserver:self forKeyPath:MotionDetectorStatePath];
}

@end
