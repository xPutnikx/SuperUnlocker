//
//  KeyPeripheral.m
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 3/28/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "KeyPeripheral.h"

#import "CommonConstants.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>


@interface KeyPeripheral ()<CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) NSMutableArray *subscribeCentrals;

@property (nonatomic, strong) CBMutableCharacteristic *shouldLockCharacterestic;
@property (nonatomic, strong) CBMutableCharacteristic *onPowerCharacterestic;

@property (nonatomic, assign) BOOL shouldLockMac;

@end


@implementation KeyPeripheral

+ (instancetype)sharedInstance {
    static KeyPeripheral *peripheral = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        peripheral = [[KeyPeripheral alloc] init];
    });
    return peripheral;
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

- (void)disconnect {
    self.onPower = NO;
}

- (void)lock {
    self.shouldLockMac = YES;
}

- (void)unlock {
    self.shouldLockMac = NO;
}

- (void)setShouldLockMac:(BOOL)shouldLockMac {
    if (_shouldLockMac == shouldLockMac ||
        self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    _shouldLockMac = shouldLockMac;
    [self updateValue:_shouldLockMac forCharacteristic:self.shouldLockCharacterestic];
}

- (void)updateValue:(BOOL)newValue forCharacteristic:(CBMutableCharacteristic *)characteristic {
    NSInteger i = newValue ? 1 : 0;
    NSData *data = [NSData dataWithBytes:&i length: sizeof(i)];
    
    [self.peripheralManager updateValue:data forCharacteristic:characteristic onSubscribedCentrals:self.subscribeCentrals];
}

- (void)setOnPower:(BOOL)onPower {
    if (_onPower == onPower ||
        self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    _onPower = onPower;
    [self updateValue:_onPower forCharacteristic:self.onPowerCharacterestic];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"0 peripheral did update state, %ld", peripheral.state);
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn: {
            [self createUnlockerService];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)createUnlockerService {// TODO try to make service primary
    CBUUID *serviceUuid = [CBUUID UUIDWithString:UnlockerServiceUuid];
    CBMutableService *service = [[CBMutableService alloc] initWithType:serviceUuid primary:YES];
    CBUUID *shouldLockCharacteresticUuid = [CBUUID UUIDWithString:ShouldLockCharacteristicUuid];
    self.shouldLockCharacterestic = [[CBMutableCharacteristic alloc] initWithType:shouldLockCharacteresticUuid properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
    CBUUID *onPowerCharacteresticUuid = [CBUUID UUIDWithString:OnPowerCharacteristicUuid];
    self.onPowerCharacterestic = [[CBMutableCharacteristic alloc] initWithType:onPowerCharacteresticUuid properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    service.characteristics = @[self.shouldLockCharacterestic, self.onPowerCharacterestic];
    
    [self.peripheralManager addService:service];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    NSLog(@"1 peripheral did add service");
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataLocalNameKey : [UIDevice currentDevice].name,
                                               CBAdvertisementDataServiceUUIDsKey : @[service.UUID]}];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (error == nil) {
        NSLog(@"2 peripheral did start advertising");
    } else {
        NSLog(@"2 periphral did start advertising with error: %@", error.localizedDescription);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"3 central did subscribe to characteristic with uuid %@", characteristic.UUID);
    _onPower = YES;// if someone was able to subscribe, we are on power
    NSPredicate *sameUuid = [NSPredicate predicateWithFormat:@"self.identifier.UUIDString == %@", central.identifier.UUIDString];
    NSArray *centralsWithSameUuid = [self.subscribeCentrals filteredArrayUsingPredicate:sameUuid];
    if (centralsWithSameUuid.count == 0) {
        [self.subscribeCentrals addObject:central];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"4 central did unsubscribe from characteristic with uuid %@", characteristic.UUID);
    [self.subscribeCentrals removeObject:central];
}

#pragma mark - Unused peripheral callbacks
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    NSLog(@"peripheral ready to send updates");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {
    NSLog(@"peripheral will restore state");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    NSLog(@"peripheral did receive read request");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    NSLog(@"peripheral did receive write request");
}

@end

