//
//  AppDelegate.m
//  MacGuarder
//
//

#import "AppDelegate.h"
#import "MacGuarder.h"
#import "BluetoothListener.h"
#import "CommonConstants.h"
#import "LockCentral.h"
#import "DeviceSelector.h"
#import "Settings.h"

#import <IOBluetooth/IOBluetooth.h>
#import <IOBluetoothUI/IOBluetoothUI.h>

//key pair auth
//первый запрос делать с данными

//central = client (macbook)
//periferial = server (phone)


@interface AppDelegate () <NSTextFieldDelegate>

@property (nonatomic, strong) Settings *settings;
@property (nonatomic, strong) MacGuarder *macGuard;
@property (nonatomic, strong) LockCentral *lockCentral;
@property (nonatomic, strong) BluetoothListener *bluetoothListener;

@end


@implementation AppDelegate

- (IBAction)selectDevice:(id)sender {
    DeviceSelector *deviceSelector = [[DeviceSelector alloc] init];
    [deviceSelector selectDeviceWithHandler:^(IOBluetoothDevice *device) {
        NSString *name = device.name;
        self.settings.deviceName = name;
        if (name != nil) {
            self.deviceNameCell.title = name;
        }
        self.bluetoothListener.device = device;
    }];
}

#pragma mark default methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.settings = [[Settings alloc] init];
    if (self.settings.deviceName.length > 0) {
        self.deviceNameCell.title = self.settings.deviceName;
    } else {
        self.deviceNameCell.title = @"Please select device";
    }
    
    self.selectDeviceButton.enabled = YES;
    self.passwordField.stringValue = self.settings.password;
    
    self.macGuard = [[MacGuarder alloc] initWithSettings:self.settings];
    self.lockCentral = [LockCentral sharedInstance];
    
    __weak typeof(self) welf = self;
    self.lockCentral.shouldConnectDeviceHandler = ^BOOL(NSString *deviceName) {
        return [welf.settings.deviceName isEqualToString:deviceName];
    };
    self.lockCentral.lockCommandHandler = ^() {
        [welf.macGuard lock];
    };
    self.lockCentral.unlockCommandHandler = ^() {
        [welf.macGuard unlock];
    };
    
    self.bluetoothListener = [[BluetoothListener alloc] init];
    self.bluetoothListener.bluetoothStatusChangedBlock = ^(BluetoothStatus bluetoothStatus) {
        switch (bluetoothStatus) {
            case BluetoothStatusInRange: {
                [welf.macGuard unlock];
                break;
            }
            case BluetoothStatusOutOfRange: {
                [welf.macGuard lock];
                break;
            }
        }
    };
}

- (void)applicationWillTerminate:(NSNotification *)notification {
//    [self.bluetoothListener stopListen];
    [self.lockCentral stop];
    [self.settings saveSettings];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)updateBluetoothStatus:(BluetoothStatus)bluetoothStatus {
//    NSImage *img = [NSImage imageNamed:(bluetoothStatus == InRange) ? @"on" : @"off"];
//
//    __weak typeof(self) weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        typeof(weakSelf) strongSelf = weakSelf;
////        [strongSelf.bluetoothStatus setImage:img];
////        [strongSelf.bluetoothStatus setNeedsDisplay:YES];
//    });
}

- (void)makeAction:(id)sender {
    NSLog(@"@Out of range");
    [self.macGuard lock];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    self.settings.password = [textField stringValue];
}

@end
