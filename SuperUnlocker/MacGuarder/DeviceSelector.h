//
//  DeviceSelector.h
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 4/11/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetoothUI/objc/IOBluetoothDeviceSelectorController.h>


typedef void (^DeviceSelectionHandler)(IOBluetoothDevice *device);


@interface DeviceSelector : NSObject

- (void)selectDeviceWithHandler:(DeviceSelectionHandler)onChange;

@end
