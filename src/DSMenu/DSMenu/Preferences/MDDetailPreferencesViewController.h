//
//  MDDetailPreferencesViewController.h
//  DSMenu
//
//  Created by Jonas Schnelli on 03.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

/**
 * \ingroup OSX
 */

#import <Cocoa/Cocoa.h>
#import "RHPreferences.h"

@interface MDDetailPreferencesViewController : NSViewController <RHPreferencesViewControllerProtocol>
@property IBOutlet NSButton *launchAtStartupButton;
@property (assign) BOOL launchAtStartup;
@end
