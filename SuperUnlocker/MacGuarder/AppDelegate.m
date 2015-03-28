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
    [[NSRunningApplication currentApplication] terminate];
}

- (IBAction)didClickSelectDevice:(id) sender{
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
    [_authorizationView setString:kAUTH_RIGHT_CONFIG_MODIFY];

    // setup
    [_authorizationView setAutoupdate:YES];
    [_authorizationView setDelegate:self];
}

#pragma mark - delegate

- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view {
    _tfMacPassword.Enabled = YES;

    AuthorizationRights *rights = self.authorizationView.authorizationRights;
    AuthorizationItem *items = rights->items;
    for (int i = 0; i < rights->count; ++i) {
        NSLog(@"%s", items[i].name);
    }
}

- (void)authorizationViewDidDeauthorize:(SFAuthorizationView *)view {
    _tfMacPassword.Enabled = NO;
}


#pragma mark central methods

//start scan for server
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"0");
            [centmanager scanForPeripheralsWithServices:
                    @[
                            [CBUUID UUIDWithString:@"FC44DD96-71BC-DFB0-BA4D-9B0D5089A3EB"],
                            [CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"]
                    ]                           options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
            break;

        default:
            NSLog(@"%i", central.state);
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
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral {
    NSLog(@"Connected:%@", aPeripheral.name);
    NSLog(@"2");
    connectedDevice = aPeripheral.name;
    [aCperipheral setDelegate:self];
    [aCperipheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    NSLog(@"3");
    for (CBService *aService in aPeripheral.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"]]) {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
    }
}


- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"4");
    for (CBCharacteristic *aChar in service.characteristics) {
        NSLog(@"%@", aChar.UUID);
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"DA18"]]) {
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
    if([aPeripheral.name isEqualToString:connectedDevice] && connected) {
        if ([_macGuarderHelper isScreenLocked]) {
            [_macGuarderHelper unlock];
        } else {
            [_macGuarderHelper lock];
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
    self.btSaveDevice.Enabled = NO;
    self.btStart.Enabled = NO;
    self.btStop.Enabled = NO;

    // startup
    self.user = [NSString stringWithFormat:@"%d", getuid()];
//    [self trackFavoriteDevicesNow];
    //*/

}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self.bluetoothListener stopListen];
}

- (void)updateBluetoothStatus:(BluetoothStatus)bluetoothStatus
{
    NSImage *img = [NSImage imageNamed:(bluetoothStatus == InRange) ? @"on" : @"off"];

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{

        [weakSelf.bluetoothStatus setImage:img];
        [weakSelf.bluetoothStatus setNeedsDisplay:YES];
    });
}
@end
