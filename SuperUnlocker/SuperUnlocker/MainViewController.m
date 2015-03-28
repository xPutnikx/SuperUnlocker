//
//  MainViewController.m
//  SuperUnlocker
//
//  Created by Vladimir Hudnitsky on 3/21/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "MainViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MainViewController()

@property (nonatomic, strong) AVAudioPlayer *player;

@end


@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    centmanager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
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

- (IBAction)disconnect:(id)sender {
    [centmanager cancelPeripheralConnection:aCperipheral];
}



- (void)willEnterBackgroud{
    [centmanager stopScan];
}

- (void)willBacktoForeground{
    [centmanager scanForPeripheralsWithServices:nil options:nil];
}

- (IBAction)clickToSend:(id)sender {
    [centmanager scanForPeripheralsWithServices:
            @[
                    [CBUUID UUIDWithString:@"FC44DD96-71BC-DFB0-BA4D-9B0D5089A3EB"],
                    [CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"]
            ] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


@end
