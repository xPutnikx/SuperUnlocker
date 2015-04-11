//
//  Settings.m
//  MacGuarder
//
//  Created by Vitalii Parovishnyk on 1/19/15.
//
//

#import "Settings.h"

static NSString * const DeviceNameKey = @"BluetoothDevice";
static NSString * const BluetoothMonitoringKey = @"BluetoothMonitoring";
static NSString * const PasswordKey = @"UserPassword";


@interface Settings ()

@property (nonatomic, strong) NSUserDefaults *defaults;

@end


@implementation Settings

- (instancetype)init {
	if (self = [super init]) {
		NSString *bundleIdentifier = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
		bundleIdentifier = [@"sandbox." stringByAppendingString:bundleIdentifier];
        
		self.defaults = [[NSUserDefaults alloc] initWithSuiteName:bundleIdentifier];
		[self initialize];
		[self loadSettings];
	}
	
	return self;
}

- (void)initialize {
    // Create a dictionary
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    defaultValues[BluetoothMonitoringKey] = @NO;
    defaultValues[PasswordKey] = @"";

    // Register the dictionary of defaults
    [self.defaults registerDefaults: defaultValues];
}

- (void)loadSettings {
    self.deviceName = [self.defaults stringForKey:DeviceNameKey];
    self.password = [self.defaults stringForKey:PasswordKey];
	// Monitoring enabled
    self.bMonitoringBluetooth = [self.defaults boolForKey:BluetoothMonitoringKey];
}


- (void)saveSettings {
    [self.defaults setObject:self.password forKey:PasswordKey];
    [self.defaults setObject:self.deviceName forKey:DeviceNameKey];
    [self.defaults synchronize];
}

@end
