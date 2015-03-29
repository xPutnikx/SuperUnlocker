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

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) IBOutlet UIButton *lockButton;

@end


@implementation PeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peripheral = [Peripheral sharedInstance];
    self.lockButton.selected = NO;// unlock for selected, lock for not selected

    
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
    self.lockButton.selected = !self.lockButton.selected;
    if (self.lockButton.selected) {//// unlock for selected, lock for not selected
        [self.peripheral unlock];
    } else {
        [self.peripheral lock];
    }
}

@end