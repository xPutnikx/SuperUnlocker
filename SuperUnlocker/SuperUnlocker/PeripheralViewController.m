//
// Created by Vladimir Hudnitsky on 3/28/15.
// Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>
#import "PeripheralViewController.h"
#import "KeyPeripheral.h"
#import "BluetoothMonitor.h"
#import "MotionDetector.h"

static NSString *const BluetoothStatePath = @"bluetoothOn";


@interface PeripheralViewController()

@property (nonatomic, strong) KeyPeripheral *peripheral;

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) IBOutlet UIButton *lockButton;

@property (nonatomic, strong) BluetoothMonitor *bluetoothMonitor;

@property (nonatomic, weak) IBOutlet UIImageView *offStateImage;

@end


@implementation PeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.offStateImage.hidden = YES;
    self.bluetoothMonitor = [[BluetoothMonitor alloc] init];
    [self.bluetoothMonitor addObserver:self forKeyPath:BluetoothStatePath options:NSKeyValueObservingOptionNew context:nil];
    
    self.peripheral = [KeyPeripheral sharedInstance];
    self.lockButton.selected = NO;// unlock for selected, lock for not selected
    
    NSURL *audioFileLocationURL = [[NSBundle mainBundle] URLForResource:@"silence" withExtension:@"caf"];
    
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileLocationURL error:&error];
    [self.player setNumberOfLoops:NSIntegerMax];
    
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

- (IBAction)changeLockState:(id)sender {
    if (self.lockButton.selected) {//// unlock for selected, lock for not selected
        [self.peripheral unlock];
    } else {
        [self.peripheral lock];
    }
    self.lockButton.selected = !self.lockButton.selected;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:BluetoothStatePath]) {
        BOOL isOn = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        self.offStateImage.hidden = isOn;
        self.lockButton.hidden = !isOn;
    }
}

- (void)dealloc {
    [self.bluetoothMonitor removeObserver:self forKeyPath:BluetoothStatePath];
}

@end