//
//  LockCentral.m
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 4/1/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "LockCentral.h"
#import "CommonConstants.h"
#import "MacGuarderHelper.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface LockCentral ()<CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSUUID *connectedPeripheralId;
@property (nonatomic, strong) MacGuarderHelper *macGuarder;

@property (nonatomic, strong) NSTimer *connectionTimer;

@end


@interface LockCentral (PeripheralDelegate)<CBPeripheralDelegate>

@end


@implementation LockCentral

+ (instancetype)sharedInstance {
    static LockCentral *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LockCentral alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

+ (void)setMacGuarder:(MacGuarderHelper *)macGuarder {
    [LockCentral sharedInstance].macGuarder = macGuarder;
}

- (void)start {
    [self startScanning];
}

- (void)startScanning {
    NSLog(@"central starts scanning");

    // if app is in background on iOS device it has no services, i.e. won't be found
    [self.centralManager scanForPeripheralsWithServices:nil/*@[[CBUUID UUIDWithString:UnlockerServiceUuid]]*/
                                                options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @(YES)}];
}

- (void)stop {
    [self.centralManager stopScan];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"%@", self.password);
    switch (central.state) {
        case CBCentralManagerStatePoweredOn: {
            NSLog(@"0 central is on");
            [self startScanning];
            break;
        }
        default: {
            NSLog(@"central is in some other state %ld", (long)central.state);
            break;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"1 central did discover peripheral %@", aPeripheral.name);
    [central stopScan];
    NSArray *peripheralsToConnectTo = [central retrievePeripheralsWithIdentifiers:@[aPeripheral.identifier]];
    if (peripheralsToConnectTo.count == 1) {
        CBPeripheral *p = [peripheralsToConnectTo firstObject];
        [central connectPeripheral:p options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey : @(YES)}];
    } else if (peripheralsToConnectTo.count > 1) {
        NSLog(@"to many peripherals retrieved");
    } else {
        NSLog(@"no peripherals retrieved");
    }
//    [central connectPeripheral:aPeripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey : @(YES)}];
    
//    NSDate *d = [NSDate dateWithTimeIntervalSinceNow: 3.0];
//    NSTimer *t = [[NSTimer alloc] initWithFireDate: d
//                                          interval: 1
//                                            target: self
//                                          selector:@selector(timeoutConnection:)
//                                          userInfo:@{@"peripheral" : aPeripheral}
//                                           repeats:YES];
//    
//    NSRunLoop *runner = [NSRunLoop currentRunLoop];
//    [runner addTimer:t forMode: NSDefaultRunLoopMode];
//    [t fire];
}
                            
- (void)timeoutConnection:(NSTimer *)timer {

    dispatch_async(dispatch_get_main_queue(), ^{
        CBPeripheral *peripheral = [timer.userInfo objectForKey:@"peripheral"];
        [self.centralManager cancelPeripheralConnection:peripheral];
        [timer invalidate];
        
        [self startScanning];
    });
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"central failed to connect peripheral %@ with error %@", peripheral.name, error.localizedDescription);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"2 central did connect peripheral %@", peripheral.name);
    self.connectedPeripheralId = peripheral.identifier;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:UnlockerServiceUuid]]];
    peripheral.delegate = self;
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"6 central did disconnect peripheral %@ with error %@", peripheral.name, error.localizedDescription);
    self.connectedPeripheralId = nil;
}

@end


@implementation LockCentral (PeripheralDelegate)

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    NSLog(@"3 did discover services for peripheral %@", aPeripheral.name);
    for (CBService *aService in aPeripheral.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:UnlockerServiceUuid]]) {
            NSLog(@"4 did discover unlocker service for peripheral %@", aPeripheral.name);
            [aPeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:ShouldLockCharacteristicUuid],
                                                   [CBUUID UUIDWithString:OnPowerCharacteristicUuid]]
                                      forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *aChar in service.characteristics) {
        NSLog(@"5 did discover characteristics %@", aChar.UUID);
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:ShouldLockCharacteristicUuid]]) {
            NSLog(@"%@", aChar.value);
            [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
        } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:OnPowerCharacteristicUuid]]) {
            NSLog(@"%@", aChar.value);
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
    //    connected = YES;
}

- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    int data;
    [characteristic.value getBytes:&data length:sizeof(data)];
    
    if ([characteristic.UUID.UUIDString isEqualToString:ShouldLockCharacteristicUuid]) {
        BOOL needToLock = data == 1;
        [self.macGuarder setPassword:self.password];
        
        if ([aPeripheral.identifier isEqualTo:self.connectedPeripheralId]/* && connected*/) {
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
            [self startScanning];
        }
    }
}

@end
