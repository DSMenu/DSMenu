//
//  MDZoneMenuItem.h
//  macDS
//
//  Created by Jonas Schnelli on 30.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum MDZoneMenuItemClickType {
    MDZoneMenuItemClickTypeScene,
    MDZoneMenuItemClickTypeDevice
}MDZoneMenuItemClickType;

@interface MDZoneMenuItem : NSMenuItem <NSMenuDelegate>
@property (strong) NSString *zoneId;
@property (strong) NSMenuItem *clickedSubmenu;
@property (assign) MDZoneMenuItemClickType clickType;

+ (MDZoneMenuItem *)menuItemWithZoneDictionary:(NSDictionary *)zoneDict;
@end
