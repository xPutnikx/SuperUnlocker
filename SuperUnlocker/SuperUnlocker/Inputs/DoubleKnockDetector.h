//
//  MotionDetector.h
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 3/28/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^DoubleKnockHandler)();


@interface DoubleKnockDetector : NSObject

- (instancetype) initWithDoubleKnockHandler:(DoubleKnockHandler)handler;
- (void)start;
- (void)stop;

@end
