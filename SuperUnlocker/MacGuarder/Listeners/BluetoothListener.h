//
//  BluetoothListener.h
//
//
//

#import <Foundation/Foundation.h>


@class IOBluetoothDevice;

typedef NS_ENUM(NSUInteger, BluetoothStatus) {
    BluetoothStatusInRange = 0,
    BluetoothStatusOutOfRange
};

typedef void (^BluetoothStatusHandler)(BluetoothStatus bluetoothStatus);


@interface BluetoothListener : NSObject

@property (nonatomic, strong) IOBluetoothDevice *device;
@property (nonatomic, copy) BluetoothStatusHandler bluetoothStatusChangedBlock;

- (void)start;
- (void)stop;

@end
