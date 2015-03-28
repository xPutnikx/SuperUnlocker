//
//  ListenerManager.m
//  LockMeNow
//
//  Created by Vitalii Parovishnyk on 1/27/15.
//
//

#import "ListenerManager.h"

@implementation ListenerManager

- (instancetype)initWithSettings:(GuarderUserDefaults *)aSettings
{
    if (self = [super init])
    {
        _userSettings = aSettings;
    }
    
    return self;
}

- (void)startListen
{
    NSLog(@"%@", @"start");
}

- (void)stopListen
{
    NSLog(@"%@", @"stop");
}

- (void)setUserSettings:(GuarderUserDefaults *)userSettings
{
    [self stopListen];
    
    _userSettings = userSettings;
    
    [self startListen];
}

- (void)makeAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(makeAction:)])
    {
        [self.delegate makeAction:sender];
    }
}

@end
