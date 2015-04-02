//
//  AppDelegate.m
//  MacGuarder
//
//

#import "AppDelegate.h"
#import "MacGuarderHelper.h"
#import "BluetoothListener.h"
#import "CommonConstants.h"
#import "LockCentral.h"

#import <IOBluetooth/IOBluetooth.h>
#import <IOBluetoothUI/IOBluetoothUI.h>

//key pair auth
//первый запрос делать с данными

//central = client (macbook)
//periferial = server (phone)


@interface AppDelegate () <ListenerManagerDelegate>

@property (nonatomic, strong) GuarderUserDefaults *userSettings;
@property (nonatomic, strong) MacGuarderHelper *macGuard;

@end


@implementation AppDelegate

- (IBAction)didClickQuit:(id)sender {
    [_userSettings savePass];
    [[NSRunningApplication currentApplication] terminate];
}

- (IBAction)didClickSelectDevice:(id)sender {
    [self.bluetoothListener changeDevice];
}

- (void)awakeFromNib {
    // request a default admin user right
    // PS:
    // 1. This default admin user right is shared with other app, like Apple's Preferences->Sharing,
    //    this means the lock they use are in sync mode.
    //    Once the admin user logins Mac, this kind of right is got, and their locks are automatically unlocked.
    // 2. But Apple's Preferences->Users & Groups app uses a higher super root user right,
    //    even the admin user logins Mac, this kind of right is still not got, need to input password to get it.
}

#pragma mark - delegate

- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view {

}

- (void)authorizationViewDidDeauthorize:(SFAuthorizationView *)view {

}

#pragma mark default methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.userSettings = [[GuarderUserDefaults alloc] init];
    self.macGuard = [[MacGuarderHelper alloc] initWithSettings:self.userSettings];
    [LockCentral setMacGuarder:self.macGuard];

    self.bluetoothListener = [[BluetoothListener alloc] initWithSettings:self.userSettings];
    self.bluetoothListener.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    self.bluetoothListener.bluetoothStatusChangedBlock = ^(BluetoothStatus bluetoothStatus) {
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateBluetoothStatus:bluetoothStatus];
    };
    [self.bluetoothListener startListen];
    
    //* By BLE
    self.btSelectDevice.Enabled = YES;
    self.user = [NSString stringWithFormat:@"%d", getuid()];
    self.passwordField.stringValue = _userSettings.userPassword;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self.bluetoothListener stopListen];
}

- (void)updateBluetoothStatus:(BluetoothStatus)bluetoothStatus {
    NSImage *img = [NSImage imageNamed:(bluetoothStatus == InRange) ? @"on" : @"off"];

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.bluetoothStatus setImage:img];
        [strongSelf.bluetoothStatus setNeedsDisplay:YES];
    });
}

- (void)makeAction:(id)sender {
    NSLog(@"@Out of range");
    if(![self.macGuard isScreenLocked]){
        [self.macGuard lock];
    }
//    if(centmanager != nil && aCperipheral != nil) {
//        [centmanager cancelPeripheralConnection:aCperipheral];
//        [centmanager                    scanForPeripheralsWithServices:
//                @[[CBUUID UUIDWithString:UnlockerServiceUuid]] options:
//                @{CBCentralManagerScanOptionAllowDuplicatesKey : @(YES)}];
//    }

}

@end
