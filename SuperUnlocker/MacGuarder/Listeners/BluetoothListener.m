//
//  BluetoothListener.m
//
//
//

#import "BluetoothListener.h"

#import <IOBluetooth/objc/IOBluetoothSDPServiceRecord.h>
#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>
#import <IOBluetoothUI/objc/IOBluetoothDeviceSelectorController.h>

static NSInteger const TimerInterval = 3;
static NSInteger const MaxCountdownValue = 3;
static NSInteger const MinCountdownValue = 0;


@interface BluetoothListener ()

@property (nonatomic) NSOperationQueue	*queue;

//Bluetooth
@property (nonatomic, assign) BluetoothStatus bluetoothDeviceStatus;
@property (nonatomic, strong) IOBluetoothDevice	*bluetoothDevice;

@property (nonatomic, assign) int countDownLatch;
@property (nonatomic, strong) NSTimer *bluetoothTimer;

@end


@implementation BluetoothListener

- (instancetype)init {
    self = [super init];
    if (self) {
        _bluetoothDeviceStatus = BluetoothStatusOutOfRange;
        _countDownLatch = MaxCountdownValue;
        _queue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

- (void)setDevice:(IOBluetoothDevice *)bluetoothDevice {
    if (_bluetoothDevice == bluetoothDevice) {
        return;
    }
    [self stop];
    _bluetoothDevice = bluetoothDevice;
    [self start];
}

- (void)start {
    if ([self connectDevice]) {
        self.bluetoothTimer = [NSTimer scheduledTimerWithTimeInterval:TimerInterval target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
        NSLog(@"start listen %@", self.bluetoothDevice.name);
    }
}

- (BOOL)connectDevice {
    BOOL needConnectDevice = ![self.bluetoothDevice isConnected];
    if (needConnectDevice) {
        IOReturn connectionStatus = [_bluetoothDevice openConnection:self];
        self.bluetoothDeviceStatus = BluetoothStatusOutOfRange;
        if (connectionStatus != kIOReturnSuccess) {
            NSLog(@"Can't connect bluetoth device");
            return NO;
        }
    }
    return YES;
}

- (void)stop {
    self.bluetoothDeviceStatus = BluetoothStatusOutOfRange;

    [self.bluetoothDevice closeConnection];
    [self.bluetoothTimer invalidate];
    self.bluetoothTimer = nil;
    
    [self.queue cancelAllOperations];
    
    NSLog(@"stop listen %@", self.bluetoothDevice.name);
}

- (BOOL)deviceIsInRange {
    if (self.bluetoothDevice != nil) {
        BluetoothHCIRSSIValue rssi = [_bluetoothDevice rawRSSI];
        if (rssi == 127 && !_bluetoothDevice.isConnected) {
            [_bluetoothDevice openConnection];
        }
        rssi = [_bluetoothDevice rawRSSI];
        return rssi > -60;
    }

    return NO;
}

- (void)handleTimer:(NSTimer *)theTimer {
    if ([self deviceIsInRange]) {
        self.countDownLatch = MaxCountdownValue;
        if (self.bluetoothDeviceStatus == BluetoothStatusOutOfRange) {
            NSLog(@"%@ is in range", self.bluetoothDevice.name);
            self.bluetoothDeviceStatus = BluetoothStatusInRange;
            if (self.bluetoothStatusChangedBlock != nil) {
                self.bluetoothStatusChangedBlock(self.bluetoothDeviceStatus);
            }
        }
    } else {
        --self.countDownLatch;
        if (self.bluetoothDeviceStatus == BluetoothStatusInRange) {
            if (self.countDownLatch == MinCountdownValue) {
                NSLog(@"%@ is out of range", self.device.name);
                self.bluetoothDeviceStatus = BluetoothStatusOutOfRange;
                self.bluetoothStatusChangedBlock(self.bluetoothDeviceStatus);
            }
        }
    }
}

@end
