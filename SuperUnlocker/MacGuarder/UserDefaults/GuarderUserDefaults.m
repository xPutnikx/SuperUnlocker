//
//  IGRUserDefaults.m
//  LockMeNow
//
//  Created by Vitalii Parovishnyk on 1/19/15.
//
//

#import "GuarderUserDefaults.h"

NSString *kBluetoothDevice                  = @"BluetoothDevice";
NSString *kBluetoothMonitoring              = @"BluetoothMonitoring";
NSString *kUserPassword                     = @"UserPassword";

@interface GuarderUserDefaults ()

@property (nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation GuarderUserDefaults

- (void)initialize
{
	// Create a dictionary
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	defaultValues[kBluetoothMonitoring] = @NO;
    defaultValues[kUserPassword] = @"";
	// Register the dictionary of defaults
	[self.defaults registerDefaults: defaultValues];
}

- (instancetype)init
{
	if (self = [super init])
	{
		NSString *bundleIdentifier = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
		bundleIdentifier = [@"sandbox." stringByAppendingString:bundleIdentifier];
		
		self.defaults = [[NSUserDefaults alloc] initWithSuiteName:bundleIdentifier];
		[self initialize];
		[self loadUserSettings];
	}
	
	return self;
}

- (void)loadUserSettings
{

    
	NSData *deviceAsData = [self.defaults objectForKey:kBluetoothDevice];
	if( [deviceAsData length] > 0 )
	{
		_bluetoothData = deviceAsData;
	}
	
	// Monitoring enabled
	_bMonitoringBluetooth = [self.defaults boolForKey:kBluetoothMonitoring];
    _userPassword = [self.defaults stringForKey:kUserPassword];
}

- (void)saveUserSettingsWithBluetoothData:(NSData *)bluetoothData
{

	// Monitoring enabled
	[self.defaults setBool:_bMonitoringBluetooth forKey:kBluetoothMonitoring];
	
	// Device
	if( bluetoothData )
	{
		[self.defaults setObject:bluetoothData forKey:kBluetoothDevice];
	}

    //password
    [self.defaults setObject:_userPassword forKey:kUserPassword];
	
	[self.defaults synchronize];
}

@end
