//
//  AppDelegate.h
//  MacGuarder
//
//  Created by user on 14-7-23.
//  Copyright (c) 2014年 TrendMicro. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SecurityInterface/SFAuthorizationView.h>
#import <IOBluetooth/IOBluetooth.h>

@class Settings;
@class BluetoothListener;
@class MacGuarder;

@interface AppDelegate : NSObject  <NSApplicationDelegate>

@property (nonatomic, assign) IBOutlet NSWindow *window;
@property (nonatomic, weak) IBOutlet NSSecureTextField *passwordField;
@property (nonatomic, weak) IBOutlet NSButton *selectDeviceButton;
@property (nonatomic, weak) IBOutlet NSTextFieldCell *deviceNameCell;

@property (nonatomic) BluetoothListener *bluetoothListener;

@end
