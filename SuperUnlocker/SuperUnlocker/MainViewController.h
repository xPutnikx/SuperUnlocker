//
//  MainViewController.h
//  SuperUnlocker
//
//  Created by Vladimir Hudnitsky on 3/21/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface MainViewController : UIViewController <CBCentralManagerDelegate,CBPeripheralDelegate>{
    CBCentralManager *centmanager;
    CBPeripheral *aCperipheral;
}

@end
