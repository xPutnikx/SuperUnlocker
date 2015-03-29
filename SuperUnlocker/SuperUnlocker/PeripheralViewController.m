//
// Created by Vladimir Hudnitsky on 3/28/15.
// Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>
#import "PeripheralViewController.h"
#import "Peripheral.h"

@interface PeripheralViewController()

@property (nonatomic, strong) Peripheral *peripheral;
@property (nonatomic, assign) BOOL shouldLock;

@property (nonatomic, strong) AVAudioPlayer *player;

@end


@implementation PeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peripheral = [Peripheral sharedInstance];
    
    NSURL *audioFileLocationURL = [[NSBundle mainBundle] URLForResource:@"silence" withExtension:@"caf"];
    
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileLocationURL error:&error];
    [self.player setNumberOfLoops:100];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    } else {
        //Make sure the system follows our playback status
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        
        //Load the audio into memory
        [self.player play];
    }
}

- (IBAction)sendPush:(id)sender {
    self.shouldLock = !self.shouldLock;
    self.peripheral.shouldLockMac = self.shouldLock;
}

- (IBAction)disconnect:(id)sender {
    [self.peripheral disconnect];
}

@end