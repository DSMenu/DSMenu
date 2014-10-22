//
//  MDIOSWidgetAction.m
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSWidgetAction.h"

@implementation MDIOSWidgetAction

- (BOOL)isEqual:(id)object
{
    MDIOSWidgetAction *action = (MDIOSWidgetAction *)object;
    
    if(self.actionType == MDIOSWidgetActionTypeFavorite && action.actionType == MDIOSWidgetActionTypeFavorite && self.actionType == action.actionType && [self.favoriteUUID isEqualToString:action.favoriteUUID])
    {
        return YES;
    }
    if(self.actionType == action.actionType && [self.title isEqualToString:action.title]
       && [self.widgetIconName isEqualToString:action.widgetIconName]
       && [self.zone isEqualToString:action.zone]
       && [self.group isEqualToString:action.group]
       && [self.scene isEqualToString:action.scene])
    {
        return YES;
    }
    return NO;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.actionType     = [coder decodeIntForKey:@"actionType"];
        self.title          = [coder decodeObjectForKey:@"widgetLabel"];
        self.widgetIconName = [coder decodeObjectForKey:@"widgetIconName"];
        self.zone           = [coder decodeObjectForKey:@"zone"];
        self.group          = [coder decodeObjectForKey:@"group"];
        self.scene          = [coder decodeObjectForKey:@"scene"];
        self.favoriteUUID   = [coder decodeObjectForKey:@"favoriteUUID"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:self.actionType        forKey:@"actionType"];
    [coder encodeObject:self.title          forKey:@"widgetLabel"];
    [coder encodeObject:self.widgetIconName forKey:@"widgetIconName"];
    [coder encodeObject:self.zone           forKey:@"zone"];
    [coder encodeObject:self.group          forKey:@"group"];
    [coder encodeObject:self.scene          forKey:@"scene"];
    [coder encodeObject:self.favoriteUUID   forKey:@"favoriteUUID"];
}

@end
