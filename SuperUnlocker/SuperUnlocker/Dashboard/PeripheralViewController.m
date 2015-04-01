//
// Created by Vladimir Hudnitsky on 3/28/15.
// Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "PeripheralViewController.h"
#import "KeyPeripheral.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>


@interface PeripheralViewController()

@property (nonatomic, strong) KeyPeripheral *peripheral;

@property (nonatomic, weak) IBOutlet UIButton *lockButton;
@property (nonatomic, weak) IBOutlet UIImageView *offStateImage;
@property (nonatomic, weak) IBOutlet UIView *lookingForDeviceView;

@end


@implementation PeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peripheral = [KeyPeripheral sharedInstance];
    
    @weakify(self);
    
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

    [[RACSignal combineLatest:@[RACObserve(self.peripheral, bluetoothIsOn), RACObserve(self.peripheral, hasConnectedDevice)]] subscribeNext:^(RACTuple *bluetoothAndDeviceConnection) {
        @strongify(self);
        
        RACTupleUnpack(id aBluetoothIsOn, id aHasConnectedDevice) = bluetoothAndDeviceConnection;
        BOOL bluetoothIsOn = [aBluetoothIsOn boolValue];
        BOOL hasConnectedDevice = [aHasConnectedDevice boolValue];
        
        BOOL showBlutoothIsOffState = !bluetoothIsOn;
        BOOL showNoConnectedDeviceState = bluetoothIsOn && !hasConnectedDevice;
        BOOL showNormalState = bluetoothIsOn && hasConnectedDevice;
        
        self.offStateImage.hidden = !showBlutoothIsOffState;
        self.lockButton.hidden = !showNormalState;
        self.lookingForDeviceView.hidden = !showNoConnectedDeviceState;
    }];
}

@end