//
//  Peripheral.m
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 3/28/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "Peripheral.h"

#import "CommonConstants.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>


@interface Peripheral ()<CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) NSMutableArray *subscribeCentrals;

@property (nonatomic, strong) CBMutableCharacteristic *shouldLockCharacterestic;
@property (nonatomic, strong) CBMutableCharacteristic *onPowerCharacterestic;

@property (nonatomic, assign) BOOL shouldLockMac;

@end


@implementation Peripheral

- (void)setShouldLockMac:(BOOL)shouldLockMac {
    if (_shouldLockMac == shouldLockMac) {
        return;
    }
    if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    _shouldLockMac = shouldLockMac;
    NSInteger i = shouldLockMac ? 1 : 0;
    NSData *data = [NSData dataWithBytes:&i length: sizeof(i)];
    
    [self.peripheralManager updateValue:data forCharacteristic:self.shouldLockCharacterestic onSubscribedCentrals:self.subscribeCentrals];
}

+ (instancetype)sharedInstance {
    static Peripheral *peripheral = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        peripheral = [[Peripheral alloc] init];
    });
    return peripheral;
}

- (void)setOnPower:(BOOL)onPower {
    _onPower = onPower;
    NSInteger i = self.isOnPower ? 1 : 0;
    NSData *data = [NSData dataWithBytes:&i length: sizeof(i)];
    [self.peripheralManager updateValue:data forCharacteristic:self.onPowerCharacterestic onSubscribedCentrals:self.subscribeCentrals];
}

- (void)disconnect {
    self.onPower = NO;
}

- (void)lock {
    self.shouldLockMac = YES;
}

- (void)unlock {
    self.shouldLockMac = NO;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        _subscribeCentrals = [[NSMutableArray alloc] init];
        _onPower = YES;
    }
    
    return self;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"0  peripheralManagerDidUpdateState");
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn: {
            CBUUID *serviceUuid = [CBUUID UUIDWithString:UnlockerServiceUuid];
            CBMutableService *service = [[CBMutableService alloc] initWithType:serviceUuid primary:YES];
            CBUUID *shouldLockCharacteresticUuid = [CBUUID UUIDWithString:ShouldLockCharacteristicUuid];
            self.shouldLockCharacterestic = [[CBMutableCharacteristic alloc] initWithType:shouldLockCharacteresticUuid properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
            CBUUID *onPowerCharacteresticUuid = [CBUUID UUIDWithString:OnPowerCharacteristicUuid];
            self.onPowerCharacterestic = [[CBMutableCharacteristic alloc] initWithType:onPowerCharacteresticUuid properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
            service.characteristics = @[self.shouldLockCharacterestic, self.onPowerCharacterestic];
            
            [self.peripheralManager addService:service];
            break;
        }
        default: {
            NSLog(@"state is %ld", peripheral.state);
            break;
        }
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    NSLog(@"1 didAddService");
    [self.peripheralManager startAdvertising:@{
                                               CBAdvertisementDataLocalNameKey : [UIDevice currentDevice].name,
                                               CBAdvertisementDataServiceUUIDsKey : @[service.UUID]
                                               }];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"2 peripheralManagerDidStartAdvertising");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"received read request");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    NSLog(@"received write request");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"did subscribe");
    _onPower = YES;
    NSArray *centralsWithSameUuid = [self.subscribeCentrals filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.identifier.UUIDString == %@", central.identifier.UUIDString]];
    if (centralsWithSameUuid.count == 0) {
        [self.subscribeCentrals addObject:central];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"unsubscribe");
    [self.subscribeCentrals removeObject:central];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    NSLog(@"ready to send updates");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {
    NSLog(@"will restore state");
}

@end

