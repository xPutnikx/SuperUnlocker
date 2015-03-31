//
//  BackgroundViewController.m
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 3/31/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "BackgroundViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface BackgroundViewController()

@property (nonatomic, strong) AVAudioPlayer *player;

@end


@implementation BackgroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *audioFileLocationURL = [[NSBundle mainBundle] URLForResource:@"silence" withExtension:@"caf"];
    
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileLocationURL error:&error];
    [self.player setNumberOfLoops:NSIntegerMax];
    
    if (error) {
        NSLog(@"Failed to play music with error: %@", [error localizedDescription]);
    } else {
        //Make sure the system follows our playback status
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [self.player play];//Load the audio into memory
    }
}

@end
