//
//  MDZoneMenuItem.h
//  DSMenu
//
//  Created by Jonas Schnelli on 30.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MDSceneMenuItem.h"

/**
 * MDZoneMenuItemClickType.
 *  This enum will be used to distinct the menu item type
 */
typedef enum MDZoneMenuItemClickType {
    MDZoneMenuItemClickTypeNotOfInterest,
    MDZoneMenuItemClickTypeScene, /**<  if the clicked menu item is a scene/root, this value will be used */
    MDZoneMenuItemClickTypeDevice /**< will be set on clicked menu from the "devices menu" */
} MDZoneMenuItemClickType;

/**
 * MDZoneMenuItemClickType.
 *  This class represents a Zone as a MenuItem.
 */
@interface MDZoneMenuItem : NSMenuItem <NSMenuDelegate>
@property (strong) NSString *zoneId;  /**< the connected zoneId  */
@property (strong) MDSceneMenuItem *clickedSubmenu;  /**< if a submenu was clicked, this ivar will be filled. */
@property (assign) MDZoneMenuItemClickType clickType;

+ (MDZoneMenuItem *)menuItemWithZoneDictionary:(NSDictionary *)zoneDict target:(NSObject *)aTarget;
@end
