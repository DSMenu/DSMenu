//
//  MDDeviceMenuItem.h
//  DSMenu
//
//  Created by Jonas Schnelli on 30.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MDSceneMenuItem.h"

/**
 * MDZoneMenuItemClickType.
 *  Class for Device Menu Item
 */
@interface MDDeviceMenuItem : MDSceneMenuItem
@property (strong) NSString *dsid; /**< the related dsid for this device */
@property (assign) BOOL turnOnOffMode;
@end
