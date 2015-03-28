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

@class GuarderUserDefaults;
@class BluetoothListener;
@class MacGuarderHelper;

@interface AppDelegate : NSObject  <NSApplicationDelegate, CBCentralManagerDelegate,CBPeripheralDelegate> {
    CBCentralManager *centmanager;
    CBPeripheral *aCperipheral;
}
@property (weak) IBOutlet NSSecureTextField *passwordField;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *btSelectDevice;

@property (weak) IBOutlet NSButton *btQuit;

@property (weak) IBOutlet NSImageView	*bluetoothStatus;

@property (nonatomic) GuarderUserDefaults *userSettings;
@property (nonatomic) BluetoothListener *bluetoothListener;
@property (nonatomic) MacGuarderHelper *macGuarderHelper;
@property (nonatomic, strong) NSString* user;

@end
