//
//  Settings.m
//  MacGuarder
//
//  Created by Vitalii Parovishnyk on 1/19/15.
//
//

#import "Settings.h"
#import <SSKeychain/SSKeychain.h>


static NSString * const DeviceService = @"MacGuarderDevice";
static NSString * const PasswordService = @"MacGuarderPassword";


@implementation Settings

- (instancetype)init {
    self = [super init];
	if (self) {
		[self loadSettings];
	}
	return self;
}

- (void)loadSettings {
    self.password = [SSKeychain passwordForService:@"MacGuarderPassword" account:NSFullUserName()];
    self.deviceName = [SSKeychain passwordForService:@"MacGuarderDevice" account:NSFullUserName()];
    self.bluetoothMonitoringEnabled = NO;
}

- (void)saveSettings {
    NSString *account = NSFullUserName();
    if (self.password == nil) {
        [SSKeychain deletePasswordForService:PasswordService account:account];
    } else {
        [SSKeychain setPassword:self.password forService:PasswordService account:account];
    }
    if (self.deviceName == nil) {
        [SSKeychain deletePasswordForService:DeviceService account:account];
    } else {
        [SSKeychain setPassword:self.deviceName forService:DeviceService account:account];
    }
}

@end
