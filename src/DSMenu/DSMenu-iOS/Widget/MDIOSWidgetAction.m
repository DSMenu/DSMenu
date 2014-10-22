//
//  MDIOSWidgetAction.m
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSWidgetAction.h"

@implementation MDIOSWidgetAction

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.actionType     = [coder decodeIntForKey:@"actionType"];
        self.title    = [coder decodeObjectForKey:@"widgetLabel"];
        self.widgetIconName = [coder decodeObjectForKey:@"widgetIconName"];
        self.zone           = [coder decodeObjectForKey:@"zone"];
        self.group          = [coder decodeObjectForKey:@"group"];
        self.scene          = [coder decodeObjectForKey:@"scene"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:self.actionType        forKey:@"actionType"];
    [coder encodeObject:self.title    forKey:@"widgetLabel"];
    [coder encodeObject:self.widgetIconName forKey:@"widgetIconName"];
    [coder encodeObject:self.zone           forKey:@"zone"];
    [coder encodeObject:self.group          forKey:@"group"];
    [coder encodeObject:self.scene          forKey:@"scene"];
}

@end
