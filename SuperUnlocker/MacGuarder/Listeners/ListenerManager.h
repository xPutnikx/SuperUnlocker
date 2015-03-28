//
//  ListenerManager.h
//  LockMeNow
//
//  Created by Vitalii Parovishnyk on 1/27/15.
//
//

#import <Foundation/Foundation.h>
#import "GuarderUserDefaults.h"

@class GuarderUserDefaults;

@protocol ListenerManagerDelegate <NSObject>

- (void)makeAction:(id)sender;

@end

@interface ListenerManager : NSObject

- (instancetype)initWithSettings:(GuarderUserDefaults *)aSettings NS_DESIGNATED_INITIALIZER;

- (void)startListen;
- (void)stopListen;
- (void)makeAction:(id)sender;

@property (nonatomic, weak  ) GuarderUserDefaults *userSettings;
@property (nonatomic, weak  ) id<ListenerManagerDelegate> delegate;

@end
