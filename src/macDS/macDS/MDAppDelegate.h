//
//  MDAppDelegate.h
//  macDS
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum MDAppState {
    MDAppStateBootstrapping, /**< enum state for booting the app */
    MDAppStateLoadingStructure,
    MDAppStateAuthError,
    MDAppStateWaitingForAccess,
    MDAppStateIdel
}MDAppState;

@interface MDAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>

@property (assign) IBOutlet NSWindow *window;

@end
