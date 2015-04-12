//
//  DeviceSelector.m
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 4/11/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "DeviceSelector.h"
#import <IOBluetooth/IOBluetooth.h>


@implementation DeviceSelector

- (void)selectDeviceWithHandler:(DeviceSelectionHandler)onChange {
    IOBluetoothDeviceSelectorController *deviceSelector = [IOBluetoothDeviceSelectorController deviceSelector];
    [deviceSelector runModal];
    NSArray *results = [deviceSelector getResults];
    if (results.count < 1) {     // canceled selection or nothing was selected
        return;
    }
    IOBluetoothDevice *bluetoothDevice = [results firstObject];
    onChange(bluetoothDevice);
}

@end
