//
//  MDAppDelegate.h
//  DSMenu
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MDStepMenuItemDelegate.h"

/**
 * \ingroup OSX
 */

typedef enum MDAppState {
    MDAppStateBootstrapping, /**< enum state for booting the app */
    MDAppStateLoadingStructure,
    MDAppStateAuthError,
    MDAppStateWaitingForAccess,
    MDAppStateIdel
}MDAppState;

@interface MDAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate, MDStepMenuItemDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) BOOL launchAtStartup;

@end
