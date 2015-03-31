//
//  KeyPeripheral.h
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 3/28/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KeyPeripheral : NSObject

@property (nonatomic, assign) BOOL bluetoothIsOn;

+ (instancetype)sharedInstance;

- (void)lock;
- (void)unlock;

- (void)disconnect;

@end
