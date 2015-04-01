//
//  SubscribersStore.h
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 4/1/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface SubscribersStore : NSObject

@property (nonatomic, assign) BOOL subscribersExist;

- (void)central:(CBCentral *)central didSubscribeForCharacteristic:(CBCharacteristic *)characteristic;
- (void)central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic;
- (NSArray *)subscribedCentrals;
- (NSArray *)subscribedCentralsForCharacteristic:(CBCharacteristic *)characteristic;

@end
