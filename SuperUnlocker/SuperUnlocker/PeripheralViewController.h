//
// Created by Vladimir Hudnitsky on 3/28/15.
// Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CBMutableService;
@class SFAuthorizationView;


@interface PeripheralViewController : UIViewController<CBPeripheralManagerDelegate>
{
    CBPeripheralManager *manager;
    CBMutableCharacteristic *characteristic;
    CBMutableCharacteristic *characteristic1;
    CBMutableCharacteristic *characteristic2;
    CBMutableService *servicea;
    NSData *mainData;
    NSString *range;

}
@end