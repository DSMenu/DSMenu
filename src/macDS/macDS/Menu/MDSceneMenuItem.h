//
//  MDSceneMenuItem.h
//  macDS
//
//  Created by Jonas Schnelli on 01.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * MDZoneMenuItemClickType.
 *  Class for Scene Menu Item
 */
@interface MDSceneMenuItem : NSMenuItem
@property (assign) NSInteger group; /**< group Number (ex. 1 = yellow) which will be used for further actions */
@end
