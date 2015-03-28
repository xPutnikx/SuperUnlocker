//
//  AppDelegate.m
//  MacGuarder
//
//  Created by user on 14-7-23.
//  Copyright (c) 2014年 TrendMicro. All rights reserved.
//

#import "AppDelegate.h"
#import "MacGuarderHelper.h"
#import "BluetoothListener.h"
#import "ListenerManager.h"
#import "BluetoothListener.h"

#define kAUTH_RIGHT_CONFIG_MODIFY    "com.trendmicro.iTIS.MacGuarder"

@interface AppDelegate () <ListenerManagerDelegate>


@end

@implementation AppDelegate{
    NSString *connectedDevice;
}

- (instancetype)init {
    if (self = [super init]) {
        self.userSettings = [[GuarderUserDefaults alloc] init];
    }

    return self;
}


#pragma mark - UI action

- (IBAction)didClickSelectDevice:(id)sender {
    self.lbSelectedDevice.stringValue = @"Selecting Device";
}

- (IBAction)didClickSaveDevice:(id)sender {
}
- (IBAction)didClickStart:(id)sender {
    self.btStart.Enabled = NO;
    self.btSelectDevice.Enabled = NO;
    self.btSaveDevice.Enabled = NO;
    self.tfMacPassword.Enabled = NO;

    [_macGuarderHelper setPassword:self.tfMacPassword.stringValue];
    self.btStop.Enabled = YES;
}

- (IBAction)didClickStop:(id)sender {
    self.btStop.Enabled = NO;

    self.tfMacPassword.Enabled = YES;
    self.btStart.Enabled = YES;
    self.btSelectDevice.Enabled = YES;
    self.btSaveDevice.Enabled = YES;
}

- (IBAction)didClickQuit:(id)sender {
    [[NSRunningApplication currentApplication] terminate];
}

- (IBAction)testService:(id)sender {

}

#pragma mark - startup

- (void)trackFavoriteDevicesNow {
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

#pragma mark - GUI

- (void)updateBluetoothStatus:(BluetoothStatus)bluetoothStatus {
    NSImage *img = [NSImage imageNamed:(bluetoothStatus == InRange) ? @"on" : @"off"];

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{

        [weakSelf.bluetoothStatus setImage:img];
        [weakSelf.bluetoothStatus setNeedsDisplay:YES];
    });
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


#pragma mark peripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"0");
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn: {
            CBUUID *cUDID = [CBUUID UUIDWithString:@"DA18"];
            CBUUID *cUDID1 = [CBUUID UUIDWithString:@"DA17"];
            CBUUID *cUDID2 = [CBUUID UUIDWithString:@"DA16"];


            CBUUID *sUDID = [CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"];
            characteristic = [[CBMutableCharacteristic alloc] initWithType:cUDID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
            characteristic1 = [[CBMutableCharacteristic alloc] initWithType:cUDID1 properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
            characteristic2 = [[CBMutableCharacteristic alloc] initWithType:cUDID2 properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
            NSLog(@"characteristic %ld, %ld, %ld", characteristic.properties, characteristic1.properties, characteristic2.properties);
            servicea = [[CBMutableService alloc] initWithType:sUDID primary:YES];
            servicea.characteristics = @[characteristic, characteristic1, characteristic2];
            [peripheral addService:servicea];
        }
            break;

        default:
            NSLog(@"State %li", peripheral.state);
            break;
    }
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSString *mainString = [NSString stringWithFormat:@"GN123"];
    NSData *cmainData = [mainString dataUsingEncoding:NSUTF8StringEncoding];
    request.value = cmainData;
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    for (CBATTRequest *aReq in requests) {
        NSLog([[NSString alloc] initWithData:aReq.value encoding:NSUTF8StringEncoding]);
        if([connectedDevice isEqualToString:((CBATTRequest *)requests.firstObject).central.identifier.UUIDString]) {
            if (![_macGuarderHelper isScreenLocked]) {
                [_macGuarderHelper lock];
            } else {
                [_macGuarderHelper unlock];
            }
            [peripheral respondToRequest:aReq withResult:CBATTErrorSuccess];
        }
    }
}


- (void)   peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central
didSubscribeToCharacteristic:(CBCharacteristic *)characteristic12 {
    NSLog(@"Core:%@", central.identifier.UUIDString);
    NSLog(@"Connected");
    connectedDevice = central.identifier.UUIDString;
    [self writeData:peripheral];
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    NSLog(@"1");
    NSDictionary *advertisingData = @{CBAdvertisementDataLocalNameKey : @"KhaosT", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"]]};
    [peripheral startAdvertising:advertisingData];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"2");
}


- (void)writeData:(CBPeripheralManager *)peripheral {
    NSDictionary *dict = @{@"NAME" : @"Khaos Tian", @"EMAIL" : @"khaos.tian@gmail.com"};
    mainData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    while ([self hasData]) {
        if ([peripheral updateValue:[self getNextData] forCharacteristic:characteristic onSubscribedCentrals:nil]) {
            [self ridData];
        } else {
            return;
        }
    }
    NSString *stra = @"ENDAL";
    NSData *dataa = [stra dataUsingEncoding:NSUTF8StringEncoding];
    [peripheral updateValue:dataa forCharacteristic:characteristic onSubscribedCentrals:nil];
}

#pragma mark supported methods

- (BOOL)hasData {
    if ([mainData length] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)ridData {
    if ([mainData length] > 19) {
        mainData = [mainData subdataWithRange:NSRangeFromString(range)];
    } else {
        mainData = nil;
    }
}

- (NSData *)getNextData {
    NSData *data;
    if ([mainData length] > 19) {
        unsigned long datarest = [mainData length] - 20;
        data = [mainData subdataWithRange:NSRangeFromString(@"{0,20}")];
        range = [NSString stringWithFormat:@"{20,%lu}", datarest];
    } else {
        unsigned long datarest = [mainData length];
        range = [NSString stringWithFormat:@"{0,%lu}", datarest];
        data = [mainData subdataWithRange:NSRangeFromString(range)];
    }
    return data;
}

- (void)makeAction:(id)sender {

}

#pragma mark - Bluetooth

- (IBAction)changeDevice:(id)sender {
    [self.bluetoothListener changeDevice];
}

#pragma mark default methods


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _macGuarderHelper = [[MacGuarderHelper alloc] initWithSettings:self.userSettings];
  
    manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 1)];

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

@end
