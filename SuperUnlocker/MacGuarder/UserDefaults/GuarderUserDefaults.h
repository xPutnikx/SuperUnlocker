//
//  IGRUserDefaults.h
//  LockMeNow
//
//  Created by Vitalii Parovishnyk on 1/19/15.
//
//

#import <Foundation/Foundation.h>

typedef void (^IGRUserDefaultsBluetoothData)(NSData *bluetoothData);

@interface GuarderUserDefaults : NSObject

@property (nonatomic, assign) BOOL bMonitoringBluetooth;
@property (nonatomic, strong) NSData *bluetoothData;
@property (nonatomic, assign) NSString *userPassword;

- (void)loadUserSettings;
- (void)saveUserSettingsWithBluetoothData:(NSData *)bluetoothData;
- (void)savePass;

@end
