//
//  MDStepMenuItem.h
//  DSMenu
//
//  Created by Jonas Schnelli on 25.09.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MDStepMenuItemDelegate.h"

@interface MDStepMenuItem : NSMenuItem
@property (assign) NSObject <MDStepMenuItemDelegate> *stepTarget;
@property (strong) NSString *zoneId;
@property (assign) int groupId;
@property (assign) BOOL callToDSSInProgress;
@property (assign) BOOL incrementPressed;
@end
