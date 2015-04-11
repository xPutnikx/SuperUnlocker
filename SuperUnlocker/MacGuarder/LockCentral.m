//
//  LockCentral.m
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 4/1/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "LockCentral.h"
#import "CommonConstants.h"
#import "MacGuarder.h"
#import "GuarderUserDefaults.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface LockCentral ()<CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, strong) MacGuarder *macGuarder;

@end


@interface LockCentral (PeripheralDelegate)<CBPeripheralDelegate>

@end


@implementation LockCentral

- (instancetype)init {
    self = [super init];
    if (self) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

#pragma mark - Public

+ (instancetype)sharedInstance {
    static LockCentral *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LockCentral alloc] init];
    });
    return instance;
}

+ (void)setMacGuarder:(MacGuarder *)macGuarder {
    [LockCentral sharedInstance].macGuarder = macGuarder;
}

- (void)start {
    NSLog(@"start");
    [self scanForPeripherals];
}

- (void)stop {
    NSLog(@"stop");
    [self cancelScanForPeripherals];
    [self.centralManager cancelPeripheralConnection:self.peripheral];
}

#pragma mark - Scanning

- (void)scanForPeripherals {
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    NSLog(@"scanning...");
    
    // By turning on allow duplicates, it allows us to scan more reliably, but
    // if it finds a peripheral that does not have the services we like or
    // recognize, we'll continually see it again and again in the didDiscover
    // callback.
    NSDictionary *scanningOptions = @{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES };
    
    // We could pass in the set of serviceUUIDs when scanning like Apple
    // recommends, but if the application we're scanning for is in the background
    // on the iOS device, then it occassionally will not see any services.
    //
    // So instead, we do the opposite of what Apple recommends and scan
    // with no service UUID restrictions.
    [self.centralManager scanForPeripheralsWithServices:nil options:scanningOptions];
}

- (void)cancelScanForPeripherals {
    [self.centralManager stopScan];
}

#pragma mark -

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn: {
            NSLog(@"central is on");
            [self scanForPeripherals];
            break;
        }
        default: {
            NSLog(@"central is in some other state %ld", (long)central.state);
            break;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([self.peripheral.identifier isEqualTo:aPeripheral.identifier] ||
        ![aPeripheral.name isEqualToString:self.macGuarder.userSettings.selectedDeviceName]) {
        return;
    }
    NSLog(@"did discover peripheral %@", aPeripheral.name);
    self.peripheral = aPeripheral;
    [central connectPeripheral:aPeripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey : @(YES)}];
}

#pragma mark - Connection Handling
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"failed to connect peripheral %@ with error %@", peripheral.name, error.localizedDescription);
    self.peripheral = nil;
    [self scanForPeripherals];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"did connect peripheral %@", peripheral.name);
    [peripheral discoverServices:@[[CBUUID UUIDWithString:UnlockerServiceUuid]]];
    peripheral.delegate = self;
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"did disconnect peripheral %@ with error %@", peripheral.name, error.localizedDescription);
    self.peripheral = nil;
}

@end


@implementation LockCentral (PeripheralDelegate)

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    NSLog(@"did discover services for peripheral %@", aPeripheral.name);
    for (CBService *aService in aPeripheral.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:UnlockerServiceUuid]]) {
            NSLog(@"did discover unlocker service for peripheral %@", aPeripheral.name);
            [aPeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:ShouldLockCharacteristicUuid],
                                                   [CBUUID UUIDWithString:OnPowerCharacteristicUuid]]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"did discover characteristics for peripheral %@", aPeripheral.name);
    for (CBCharacteristic *aChar in service.characteristics) {
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:ShouldLockCharacteristicUuid]]) {
            [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
        } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:OnPowerCharacteristicUuid]]) {
            [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    int data;
    [characteristic.value getBytes:&data length:sizeof(data)];
    
    if ([characteristic.UUID.UUIDString isEqualToString:ShouldLockCharacteristicUuid]) {
        BOOL needToLock = data == 1;
        
        if ([aPeripheral.identifier isEqualTo:self.peripheral.identifier]) {
            BOOL isLocked = [self.macGuarder isScreenLocked];
            if (needToLock && !isLocked) {
                [self.macGuarder lock];
            }
            BOOL needUnlock = !needToLock;
            if (needUnlock && isLocked) {
                [self.macGuarder unlock];
            }
        }
    } else if ([characteristic.UUID.UUIDString isEqualToString:OnPowerCharacteristicUuid]) {
        BOOL needDisconnect = data == 0;
        if (needDisconnect) {
            NSLog(@"central will unsubscribe");
            [self.centralManager cancelPeripheralConnection:aPeripheral];
            [self scanForPeripherals];
        }
    }
}

@end
