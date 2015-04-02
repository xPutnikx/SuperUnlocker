//
//  LockCentral.h
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 4/1/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MacGuarderHelper;


@interface LockCentral : NSObject

@property (nonatomic, strong) NSString *password;

+ (instancetype)sharedInstance;
+ (void)setMacGuarder:(MacGuarderHelper *)macGuarder;

- (void)start;
- (void)stop;

@end
