//
//  SubscribersStore.m
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 4/1/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import "SubscribersStore.h"


@interface SubscribersStore()

@property (nonatomic, strong) NSMutableDictionary *subscribersByCharacteristicUuid;

@end


@implementation SubscribersStore

- (instancetype)init {
    self = [super init];
    if (self) {
        self.subscribersByCharacteristicUuid = [[NSMutableDictionary alloc] init];
        self.subscribersExist = NO;
    }
    return self;
}

- (void)central:(CBCentral *)central didSubscribeForCharacteristic:(CBCharacteristic *)characteristic {
    NSMutableArray *subscribers = [self.subscribersByCharacteristicUuid objectForKey:characteristic];
    if (subscribers == nil) {
        subscribers = [[NSMutableArray alloc] initWithObjects:central, nil];
    } else if (![subscribers containsObject:central]) {
        [subscribers addObject:central];
    }
    [self.subscribersByCharacteristicUuid setObject:subscribers forKey:characteristic.UUID];
    self.subscribersExist = self.subscribersByCharacteristicUuid.count > 0;
}

- (void)central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSMutableArray *subscribers = [self.subscribersByCharacteristicUuid objectForKey:characteristic.UUID];
    if ([subscribers containsObject:central]) {
        [subscribers removeObject:central];
        if (subscribers.count == 0) {
            [self.subscribersByCharacteristicUuid removeObjectForKey:characteristic.UUID];
        }
    }
    self.subscribersExist = self.subscribersByCharacteristicUuid.count > 0;
}

- (NSArray *)subscribedCentrals {
    NSArray *listOfSubscribedCentrals = self.subscribersByCharacteristicUuid.allValues;
    NSMutableArray *uniqueCentrals = [[NSMutableArray alloc] init];
    for (NSArray *list in listOfSubscribedCentrals) {
        for (CBCentral *central in list) {
            if (![uniqueCentrals containsObject:central]) {
                [uniqueCentrals addObject:central];
            }
        }
    }
    return uniqueCentrals;
}

- (NSArray *)subscribedCentralsForCharacteristic:(CBCharacteristic *)characteristic {
    if ([self.subscribersByCharacteristicUuid objectForKey:characteristic.UUID] != nil) {
        return [self.subscribersByCharacteristicUuid objectForKey:characteristic.UUID];
    }
    return @[];
}


@end
