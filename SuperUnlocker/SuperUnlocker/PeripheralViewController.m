//
// Created by Vladimir Hudnitsky on 3/28/15.
// Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "PeripheralViewController.h"
#import "KeyPeripheral.h"
#import "BluetoothMonitor.h"
#import "MotionDetector.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>


@interface PeripheralViewController()

@property (nonatomic, strong) KeyPeripheral *peripheral;

@property (nonatomic, strong) IBOutlet UIButton *lockButton;
@property (nonatomic, weak) IBOutlet UIImageView *offStateImage;

@end


@implementation PeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peripheral = [KeyPeripheral sharedInstance];
    
    @weakify(self);
    [RACObserve(self.peripheral, bluetoothIsOn) subscribeNext:^(id aState) {
        @strongify(self);
        BOOL bluetoothIsOn = [aState boolValue];
        self.offStateImage.hidden = bluetoothIsOn;
        self.lockButton.hidden = !bluetoothIsOn;
    }];
    
    self.lockButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIButton *lockButton) {
        @strongify(self);
        if (lockButton.selected) {
            [self.peripheral unlock];
        } else {
            [self.peripheral lock];
        }
        lockButton.selected = !lockButton.selected;
        return [RACSignal return:nil];
    }];
}

@end