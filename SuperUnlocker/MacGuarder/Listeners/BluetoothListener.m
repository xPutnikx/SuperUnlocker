//
//  BluetoothListener.m
//
//
//

#import "BluetoothListener.h"
#import "GuarderUserDefaults.h"

#import <IOBluetooth/objc/IOBluetoothSDPServiceRecord.h>
#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>
#import <IOBluetoothUI/objc/IOBluetoothDeviceSelectorController.h>

@interface BluetoothListener ()

@property (nonatomic) NSOperationQueue	*queue;
@property (nonatomic) NSOperationQueue	*guiQueue;

//Bluetooth
@property (nonatomic) NSInteger	bluetoothTimerInterval;
@property (nonatomic) BluetoothStatus	bluetoothDevicePriorStatus;
@property (nonatomic) NSTimer			*bluetoothTimer;

@property (nonatomic) IOBluetoothDevice	*bluetoothDevice;

@end

@implementation BluetoothListener{
    int countDownLatch;
};

- (instancetype)initWithSettings:(GuarderUserDefaults *)aSettings
{
    if (self = [super initWithSettings:aSettings])
    {
        _checkingInProgress = NO;
        self.bluetoothDevicePriorStatus = OutOfRange;
        _bluetoothDevice = [NSKeyedUnarchiver unarchiveObjectWithData:self.userSettings.bluetoothData];
        [self updateDeviceName];
        
        _bluetoothTimerInterval = 3;
        countDownLatch = 2;
        
        _guiQueue = [[NSOperationQueue alloc] init];
        _queue = [[NSOperationQueue alloc] init];

        self.userSettings.bMonitoringBluetooth = NO;
        if (self.userSettings.bMonitoringBluetooth)
        {
            [self startListen];
        }
    }
    
    return self;
}

- (void)startListen
{
    if (![_bluetoothDevice isConnected])
    {
        IOReturn rt = [_bluetoothDevice openConnection:self];
        self.bluetoothDevicePriorStatus = OutOfRange;
        if (rt != kIOReturnSuccess)
        {
            NSLog(@"Can't connect bluetoth device");
        }
    }
    
    _bluetoothTimer = [NSTimer scheduledTimerWithTimeInterval:self.bluetoothTimerInterval
                                                       target:self
                                                     selector:@selector(handleTimer:)
                                                     userInfo:nil
                                                      repeats:YES];
    NSLog(@"start listen");
}

- (void)stopListen
{
    self.bluetoothDevicePriorStatus = OutOfRange;
    
    [_bluetoothDevice closeConnection];
    [_bluetoothTimer invalidate];
    
    [_queue cancelAllOperations];
    [_guiQueue cancelAllOperations];
    
    [[NSOperationQueue mainQueue] cancelAllOperations];
    NSLog(@"stop listen");
}

- (void)changeDevice
{
    IOBluetoothDeviceSelectorController *deviceSelector = [IOBluetoothDeviceSelectorController deviceSelector];
    [deviceSelector runModal];
    
    NSArray *results = [deviceSelector getResults];
    
    if( !results )
    {
        return;
    }
    
    _bluetoothDevice = [results firstObject];
    
    NSData *deviceAsData = [NSKeyedArchiver archivedDataWithRootObject:_bluetoothDevice];
    [self.userSettings saveUserSettingsWithBluetoothData:deviceAsData];
    
    [self updateDeviceName];
}

- (void)updateDeviceName
{
    if (_bluetoothDevice)
    {
        self.bluetoothName  = [NSString stringWithFormat:@"%@", [_bluetoothDevice name]];
    }
}

- (BOOL)isInRange
{
    if (_bluetoothDevice)
    {
//        if ([_bluetoothDevice remoteNameRequest:nil] == kIOReturnSuccess)
//        {
            BluetoothHCIRSSIValue rssi = [_bluetoothDevice rawRSSI];
//            if(rssi < -60) {
//                NSLog(@"rssi ------- %d", rssi);
//            }else{
//                NSLog(@"rssi %d", rssi);
//            }
            if(rssi == 127 && !_bluetoothDevice.isConnected){
                [_bluetoothDevice openConnection];
            }
            return rssi > -60;
//        }
    }

    return NO;
}

- (void)handleTimer:(NSTimer *)theTimer
{
//    NSLog(@"Tick");
    if (![[_queue operations] count])
    {
        [_queue addOperationWithBlock:^ {
            
            BOOL result = [self isInRange];
            
            if( result )
            {
                countDownLatch = 2;
                if( _bluetoothDevicePriorStatus == OutOfRange )
                {
                    self.bluetoothDevicePriorStatus = InRange;
                    NSLog(@"@In Range");
                }
            }
            else
            {
                --countDownLatch;
                if( _bluetoothDevicePriorStatus == InRange )
                {
                    if(countDownLatch == 0) {
                        self.bluetoothDevicePriorStatus = OutOfRange;
                        [self makeAction:self];
                    }
                }
            }
        }];
    }
}

- (void)setBluetoothDevicePriorStatus:(BluetoothStatus)bluetoothDevicePriorStatus
{
    if (_bluetoothDevicePriorStatus == bluetoothDevicePriorStatus)
    {
        return;
    }
    
    _bluetoothDevicePriorStatus = bluetoothDevicePriorStatus;
    
    if (self.bluetoothStatusChangedBlock)
    {
        self.bluetoothStatusChangedBlock(_bluetoothDevicePriorStatus);
    }
}

@end
