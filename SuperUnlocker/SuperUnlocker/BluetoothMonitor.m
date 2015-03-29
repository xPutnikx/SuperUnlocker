//
//  BluetoothMonitor.m
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 3/29/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "BluetoothMonitor.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface BluetoothMonitor()<CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;

@end


@implementation BluetoothMonitor

- (instancetype)init {
    self = [super init];
    if (self) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        [self centralManagerDidUpdateState:self.centralManager];
    }
    return self;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn: {
            self.bluetoothOn = YES;
            break;
        }
        case CBCentralManagerStatePoweredOff: {
            self.bluetoothOn = NO;
            break;
        }
        default: {
            break;
        }
    }
}

@end
