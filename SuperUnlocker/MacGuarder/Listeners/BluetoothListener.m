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
@property (nonatomic, copy) BluetoothStatusHandler bluetoothStatusChangedHandler;

@property (nonatomic, assign) int countDownLatch;
@property (nonatomic, strong) NSTimer *bluetoothTimer;

@end


@implementation BluetoothListener

- (instancetype)initWithStatusHandler:(BluetoothStatusHandler)onStatusChange {
    self = [super init];
    if (self) {
        _bluetoothDeviceStatus = BluetoothStatusOutOfRange;
        _bluetoothStatusChangedHandler = onStatusChange;
        _countDownLatch = MaxCountdownValue;
        _queue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

- (void)setDevice:(IOBluetoothDevice *)bluetoothDevice {
    if (_device == bluetoothDevice) {
        return;
    }
    [self stop];
    _device = bluetoothDevice;
    [self start];
}

- (void)start {
    if ([self connectDevice]) {
        self.bluetoothTimer = [NSTimer scheduledTimerWithTimeInterval:TimerInterval target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
        NSLog(@"start listen %@", self.device.name);
    }
}

- (BOOL)connectDevice {
    BOOL needConnectDevice = ![self.device isConnected];
    if (needConnectDevice) {
        IOReturn connectionStatus = [_device openConnection:self];
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

    [self.device closeConnection];
    [self.bluetoothTimer invalidate];
    self.bluetoothTimer = nil;
    
    [self.queue cancelAllOperations];
    
    NSLog(@"stop listen %@", self.device.name);
}

- (BOOL)deviceIsInRange {
    if (self.device != nil) {
        BluetoothHCIRSSIValue rssi = [self.device rawRSSI];
        if (rssi == 127 && !self.device.isConnected) {
            [self.device openConnection];
        }
        return rssi > -60;
    }

    return NO;
}

- (void)handleTimer:(NSTimer *)theTimer {
    if ([self deviceIsInRange]) {
        self.countDownLatch = MaxCountdownValue;
        if (self.bluetoothDeviceStatus == BluetoothStatusOutOfRange) {
            NSLog(@"%@ is in range", self.device.name);
            self.bluetoothDeviceStatus = BluetoothStatusInRange;
            if (self.bluetoothStatusChangedHandler != nil) {
                self.bluetoothStatusChangedHandler(self.bluetoothDeviceStatus);
            }
        }
    } else {
        --self.countDownLatch;
        if (self.bluetoothDeviceStatus == BluetoothStatusInRange) {
            if (self.countDownLatch == MinCountdownValue) {
                NSLog(@"%@ is out of range", self.device.name);
                self.bluetoothDeviceStatus = BluetoothStatusOutOfRange;
                self.bluetoothStatusChangedHandler(self.bluetoothDeviceStatus);
            }
        }
    }
}

@end
