//
//  BluetoothListener.h
//
//
//

#import "ListenerManager.h"

typedef NS_ENUM(NSUInteger, BluetoothStatus)
{
    InRange = 0,
    OutOfRange
};

typedef void (^BluetoothStatusChangedBlock)(BluetoothStatus bluetoothStatus);

@interface BluetoothListener : ListenerManager

@property (nonatomic) NSString *bluetoothName;
@property (nonatomic) BOOL checkingInProgress;

@property (nonatomic, copy) BluetoothStatusChangedBlock bluetoothStatusChangedBlock;

- (void)changeDevice;

@end
