//
// Created by Vladimir Hudnitsky on 3/28/15.
// Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "PeripheralViewController.h"
#import "Peripheral.h"

@interface PeripheralViewController()

@property (nonatomic, strong) Peripheral *peripheral;
@property (nonatomic, assign) BOOL shouldLock;

@end


@implementation PeripheralViewController{
    NSString *connectedDevice;
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.peripheral = [[Peripheral alloc] init];
//    manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 1)];
}

- (IBAction)sendPush:(id)sender {
    self.shouldLock = !self.shouldLock;
    self.peripheral.shouldLockMac = self.shouldLock;
//    [self writeData:manager];
}
//
//#pragma mark - peripheral manager
//- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
//    NSLog(@"0  peripheralManagerDidUpdateState");
//    switch (peripheral.state) {
//        case CBPeripheralManagerStatePoweredOn: {
//            CBUUID *cUDID = [CBUUID UUIDWithString:@"DA18"];
//            CBUUID *cUDID1 = [CBUUID UUIDWithString:@"DA17"];
//            CBUUID *cUDID2 = [CBUUID UUIDWithString:@"DA16"];
//
//
//            CBUUID *sUDID = [CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"];
//            characteristic = [[CBMutableCharacteristic alloc] initWithType:cUDID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
//            characteristic1 = [[CBMutableCharacteristic alloc] initWithType:cUDID1 properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
//            characteristic2 = [[CBMutableCharacteristic alloc] initWithType:cUDID2 properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
//            NSLog(@"characteristic %ld, %ld, %ld", characteristic.properties, characteristic1.properties, characteristic2.properties);
//            servicea = [[CBMutableService alloc] initWithType:sUDID primary:YES];
//            servicea.characteristics = @[characteristic, characteristic1, characteristic2];
//            [peripheral addService:servicea];
//        }
//            break;
//
//        default:
//            NSLog(@"State %li", peripheral.state);
//            break;
//    }
//}
//
//
//- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
//    NSString *mainString = [NSString stringWithFormat:@"GN123"];
//    NSData *cmainData = [mainString dataUsingEncoding:NSUTF8StringEncoding];
//    request.value = cmainData;
//    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
//}
//
////call when received data
//- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
//    for (CBATTRequest *aReq in requests) {
//        NSLog([[NSString alloc] initWithData:aReq.value encoding:NSUTF8StringEncoding]);
//        //todo receives data here
//    }
//}
//
//
//- (void)   peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central
//didSubscribeToCharacteristic:(CBCharacteristic *)characteristic12 {
//    NSLog(@"3");
//    NSLog(@"Core:%@", central.identifier.UUIDString);
//    NSLog(@"Connected");
//    connectedDevice = central.identifier.UUIDString;
//    manager = peripheral;
//}
//
//
//- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
//    NSLog(@"1 didAddService");
//    NSDictionary *advertisingData = @{CBAdvertisementDataLocalNameKey : [UIDevice currentDevice].name, CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"]]};
//    [peripheral startAdvertising:advertisingData];
//}
//
//- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
//    NSLog(@"2 peripheralManagerDidStartAdvertising");
//}
//
//
//- (void)writeData:(CBPeripheralManager *)peripheral {
//    NSDictionary *dict = @{@"a" : @"a1"};
//    mainData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
//    while ([self hasData]) {
//        if ([peripheral updateValue:[self getNextData] forCharacteristic:characteristic onSubscribedCentrals:nil]) {
//            [self ridData];
//        } else {
//            return;
//        }
//    }
//}
//
//#pragma mark supported methods
//
//- (BOOL)hasData {
//    if ([mainData length] > 0) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//- (void)ridData {
//    if ([mainData length] > 19) {
//        mainData = [mainData subdataWithRange:NSRangeFromString(range)];
//    } else {
//        mainData = nil;
//    }
//}
//
//- (NSData *)getNextData {
//    NSData *data;
//    if ([mainData length] > 19) {
//        unsigned long datarest = [mainData length] - 20;
//        data = [mainData subdataWithRange:NSRangeFromString(@"{0,20}")];
//        range = [NSString stringWithFormat:@"{20,%lu}", datarest];
//    } else {
//        unsigned long datarest = [mainData length];
//        range = [NSString stringWithFormat:@"{0,%lu}", datarest];
//        data = [mainData subdataWithRange:NSRangeFromString(range)];
//    }
//    return data;
//}


@end