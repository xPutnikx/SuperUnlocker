//
// Created by Vladimir Hudnitsky on 3/28/15.
// Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LockManagerDelegate <NSObject>

- (void)unLockSuccess;
- (void)detectedWrongPassword;

@end