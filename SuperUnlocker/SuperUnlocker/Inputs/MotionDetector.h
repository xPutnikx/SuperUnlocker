//
//  MotionDetector.h
//  SuperUnlocker
//
//  Created by Sveta Dedunovich on 3/28/15.
//  Copyright (c) 2015 ProductDevBy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MotionState) {
    MotionStateUnknown
};


@interface MotionDetector : NSObject

- (void)start;

@end
