//
//  MDIOSWidgetManager.m
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSWidgetManager.h"
#import "Constantes.h"

#define kMDIOS_UD_WIDGET_ACTIONS_KEY @"MDIOSWidgetActions"
static MDIOSWidgetManager *defaultManager;

@interface MDIOSWidgetManager()
@property (strong) NSMutableDictionary *widgetActions;
@property (readonly) NSUserDefaults *userDefaultsProxy;
@end

@implementation MDIOSWidgetManager

+ (MDIOSWidgetManager *)defaultManager
{
    if(!defaultManager)
    {
        defaultManager = [[MDIOSWidgetManager alloc] init];
    }
    return defaultManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:kDSMENU_APP_GROUP_IDENTIFIER];
        NSData *possibleData = [self.userDefaultsProxy objectForKey:kMDIOS_UD_WIDGET_ACTIONS_KEY];
        if(!possibleData || ![possibleData isKindOfClass:[NSData class]])
        {
            self.widgetActions = [NSMutableDictionary dictionary];
        }
        else
        {
            self.widgetActions = [[NSKeyedUnarchiver unarchiveObjectWithData:possibleData] mutableCopy];
        }
    }
    return self;
}

- (void)persist
{
    [self.userDefaultsProxy setObject:[NSKeyedArchiver archivedDataWithRootObject:self.widgetActions] forKey:kMDIOS_UD_WIDGET_ACTIONS_KEY];
    [self.userDefaultsProxy synchronize];
}

- (void)setAction:(MDIOSWidgetAction *)action forSlot:(NSInteger)slot
{
    NSString *key = [NSString stringWithFormat:@"slot%ld", slot];
    [self.widgetActions setObject:action forKey:key];
    
    [self persist];
}

- (void)addActionForFavoriteUUID:(NSString *)uuid
{
    if(![self.widgetActions objectForKey:@"favs"])
    {
        [self.widgetActions setObject:[NSMutableArray array] forKey:@"favs"];
    }
    else
    {
        if(![[self.widgetActions objectForKey:@"favs"] isKindOfClass:[NSMutableArray class]])
        {
            [self.widgetActions setObject:[[self.widgetActions objectForKey:@"favs"] mutableCopy] forKey:@"favs"];
        }
    }
    
    MDIOSWidgetAction *action = [[MDIOSWidgetAction alloc] init];
    action.actionType = MDIOSWidgetActionTypeFavorite;
    action.favoriteUUID = uuid;
    
    if([[self.widgetActions objectForKey:@"favs"] indexOfObject:action] == NSNotFound){
        [[self.widgetActions objectForKey:@"favs"] addObject:action];
    }
    
    [self persist];
}

- (void)removeActionForFavoriteUUID:(NSString *)uuid
{
    if(![self.widgetActions objectForKey:@"favs"])
    {
        [self.widgetActions setObject:[NSMutableArray array] forKey:@"favs"];
    }
    else
    {
        if(![[self.widgetActions objectForKey:@"favs"] isKindOfClass:[NSMutableArray class]])
        {
            [self.widgetActions setObject:[[self.widgetActions objectForKey:@"favs"] mutableCopy] forKey:@"favs"];
        }
    }
    
    MDIOSWidgetAction *action = [[MDIOSWidgetAction alloc] init];
    action.actionType = MDIOSWidgetActionTypeFavorite;
    action.favoriteUUID = uuid;
    
    [[self.widgetActions objectForKey:@"favs"] removeObject:action];
    
    [self persist];
}

- (NSArray *)allFavoritesUUIDs
{
    return [self.widgetActions objectForKey:@"favs"];
}

- (void)moveSlotsFromSlot:(int)fromSlot toSlot:(int)toSlot
{
    MDIOSWidgetAction *aAction = [self actionForSlot:fromSlot];        
    // move
    if(toSlot > fromSlot)
    {
        for(int i=fromSlot+1; i<=toSlot;i++)
        {
            // move down onw slot
            MDIOSWidgetAction *moveDownAction = [self actionForSlot:i];
            if(moveDownAction)
            {
                [self.widgetActions setObject:moveDownAction forKey:[NSString stringWithFormat:@"slot%d", i-1]];
                [self.widgetActions removeObjectForKey:[NSString stringWithFormat:@"slot%d", i]];
                
            }
        }
    }
    else
    {
        for(int i=fromSlot-1; i>=toSlot;i--)
        {
            // move down onw slot
            MDIOSWidgetAction *moveDownAction = [self actionForSlot:i];
            if(moveDownAction)
            {
                [self.widgetActions setObject:moveDownAction forKey:[NSString stringWithFormat:@"slot%d", i+1]];
                [self.widgetActions removeObjectForKey:[NSString stringWithFormat:@"slot%d", i]];
                
            }
        }
        
    }
    if(aAction)
    {
        [self.widgetActions setObject:aAction forKey:[NSString stringWithFormat:@"slot%d", toSlot]];
    }
    else
    {
        [self.widgetActions removeObjectForKey:[NSString stringWithFormat:@"slot%d", toSlot]];
    }
    
    [self persist];
}

- (MDIOSWidgetAction *)actionForFavoriteUUID:(NSString *)favoriteUUID
{
    if(self.widgetActions && [self.widgetActions objectForKey:@"favs"])
    {
        for(MDIOSWidgetAction *action in [self.widgetActions objectForKey:@"favs"])
        {
            if([action.favoriteUUID isEqualToString:favoriteUUID])
            {
                return action;
            }
        }
    }
    return nil;
}

- (MDIOSWidgetAction *)actionForSlot:(NSInteger)slot
{
    NSString *key = [NSString stringWithFormat:@"slot%ld", slot];
    return [self.widgetActions objectForKey:key];
}

- (NSDictionary *)allActions
{
    return self.widgetActions;
}



- (NSUserDefaults *)userDefaultsProxy
{
    if(self.currentUserDefaults)
    {
        return self.currentUserDefaults;
    }
    return [NSUserDefaults standardUserDefaults];
}

@end

