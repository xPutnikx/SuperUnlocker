//
//  AppDelegate.m
//  MacGuarder
//
//

#import "AppDelegate.h"
#import "MacGuarderHelper.h"
#import "BluetoothListener.h"
#import <IOBluetooth/IOBluetooth.h>
#import <IOBluetoothUI/IOBluetoothUI.h>
#import "CommonConstants.h"

//key pair auth
//первый запрос делать с данными

#define kAUTH_RIGHT_CONFIG_MODIFY    "com.trendmicro.iTIS.MacGuarder"

//central = client (macbook)
//periferial = server (phone)

@interface AppDelegate () <ListenerManagerDelegate>


@end

@implementation AppDelegate {
    NSString *connectedDevice;
    BOOL connected;
}

- (instancetype)init {
    if (self = [super init]) {
        self.userSettings = [[GuarderUserDefaults alloc] init];
    }

    return self;
}

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


#pragma mark central methods

//start scan for server
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"0");
            [centmanager                    scanForPeripheralsWithServices:
                    @[[CBUUID UUIDWithString:UnlockerServiceUuid]] options:
                    @{CBCentralManagerScanOptionAllowDuplicatesKey : @(YES)}];
            break;

        default:
            NSLog(@"State %i", central.state);
            break;
    }
}

//start to connect to server
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([RSSI floatValue] >= -60.f) {
        NSLog(@"1");
        [central stopScan];
        aCperipheral = aPeripheral;
        [central connectPeripheral:aCperipheral options:nil];

    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed:%@", error);
}

//connected to peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected:%@", peripheral.name);
    NSLog(@"2");
    connectedDevice = peripheral.name;
    aCperipheral = peripheral;
    [aCperipheral setDelegate:self];
    [aCperipheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    NSLog(@"3");
    for (CBService *aService in aPeripheral.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:UnlockerServiceUuid]]) {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
    }
}


- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"4");
    for (CBCharacteristic *aChar in service.characteristics) {
        NSLog(@"%@", aChar.UUID);
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:ShouldLockCharacteristicUuid]]) {
            NSLog(@"%d", aChar.properties);
            [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
        } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:OnPowerCharacteristicUuid]]) {
            NSLog(@"%d", aChar.properties);
            [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            NSString *mainString = [NSString stringWithFormat:@"ping"];
            NSData *mainData = [mainString dataUsingEncoding:NSUTF8StringEncoding];
            [aPeripheral writeValue:mainData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"Finish Write\n");
    NSLog(@"5");
    connected = YES;
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    int data;
    [characteristic.value getBytes:&data length:sizeof(data)];
//    if (![aPeripheral.name isEqualToString:self.bluetoothListener.bluetoothName]) {
//        [centmanager cancelPeripheralConnection:aPeripheral];
//        [centmanager                    scanForPeripheralsWithServices:
//                @[[CBUUID UUIDWithString:UnlockerServiceUuid]] options:
//                @{CBCentralManagerScanOptionAllowDuplicatesKey : @(YES)}];
//        return;
//    }
    if ([characteristic.UUID.UUIDString isEqualToString:ShouldLockCharacteristicUuid]) {
        BOOL needToLock = data == 1;
        [_macGuarderHelper setPassword:self.passwordField.stringValue];
        if ([aPeripheral.name isEqualToString:connectedDevice] && connected) {
            BOOL isLocked = [_macGuarderHelper isScreenLocked];
            if (needToLock && !isLocked) {
                [_macGuarderHelper lock];
            }
            BOOL needUnlock = !needToLock;
            if (needUnlock && isLocked) {
                [_macGuarderHelper unlock];
            }
        }
    } else if ([characteristic.UUID.UUIDString isEqualToString:OnPowerCharacteristicUuid]) {
        BOOL needDisconnect = data == 0;
        if (needDisconnect) {
            NSLog(@"Unsubscribe");
            [centmanager cancelPeripheralConnection:aPeripheral];
            [centmanager                    scanForPeripheralsWithServices:
                    @[[CBUUID UUIDWithString:UnlockerServiceUuid]] options:
                    @{CBCentralManagerScanOptionAllowDuplicatesKey : @(YES)}];
        }
    }


}

- (void)willEnterBackgroud {
    [centmanager stopScan];
}

- (void)willBacktoForeground {
    [centmanager scanForPeripheralsWithServices:nil options:nil];
}


#pragma mark default methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _macGuarderHelper = [[MacGuarderHelper alloc] initWithSettings:self.userSettings];

    centmanager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    self.bluetoothListener = [[BluetoothListener alloc] initWithSettings:self.userSettings];
    self.bluetoothListener.delegate = self;
    __weak typeof(self) weakSelf = self;
    self.bluetoothListener.bluetoothStatusChangedBlock = ^(BluetoothStatus bluetoothStatus) {

        [weakSelf updateBluetoothStatus:bluetoothStatus];
    };

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

        [weakSelf.bluetoothStatus setImage:img];
        [weakSelf.bluetoothStatus setNeedsDisplay:YES];
    });
}

- (void)makeAction:(id)sender {
    NSLog(@"@Out of range");
    if(![_macGuarderHelper isScreenLocked]){
        [_macGuarderHelper lock];
    }
    if(centmanager != nil && aCperipheral != nil) {
        [centmanager cancelPeripheralConnection:aCperipheral];
        [centmanager                    scanForPeripheralsWithServices:
                @[[CBUUID UUIDWithString:UnlockerServiceUuid]] options:
                @{CBCentralManagerScanOptionAllowDuplicatesKey : @(YES)}];
    }

}

@end
