//
//  Settings.h
//  MacGuarder
//
//  Created by Vitalii Parovishnyk on 1/19/15.
//
//

#import <Foundation/Foundation.h>


@interface Settings : NSObject

@property (nonatomic, assign, getter=isBluetoothMonitoringEnabled) BOOL bluetoothMonitoringEnabled;

@property (nonatomic, assign) NSString *password;
@property (nonatomic, strong) NSString *deviceName;

- (void)saveSettings;

@end
