//
//  MacGuarderHelper.h
//  MacGuarder
//
//  Created by user on 14-7-23.
//  Copyright (c) 2014年 TrendMicro. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Settings;


@interface MacGuarder : NSObject

- (instancetype)initWithSettings:(Settings *)aSettings;

- (void)lock;
- (void)unlock;

@end
