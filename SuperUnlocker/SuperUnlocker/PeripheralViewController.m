//
// Created by Vladimir Hudnitsky on 3/28/15.
// Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralViewController.h"
#import "Peripheral.h"

@interface PeripheralViewController()

@property (nonatomic, strong) Peripheral *peripheral;
@property (nonatomic, assign) BOOL shouldLock;

@end


@implementation PeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peripheral = [Peripheral sharedInstance];
}

- (IBAction)sendPush:(id)sender {
    self.shouldLock = !self.shouldLock;
    self.peripheral.shouldLockMac = self.shouldLock;
}

- (IBAction)disconnect:(id)sender {
    [self.peripheral disconnect];
}

@end