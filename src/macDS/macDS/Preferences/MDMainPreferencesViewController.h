//
//  RHAboutViewController.h
//  RHPreferencesTester
//
//  Created by Richard Heard on 17/04/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RHPreferences.h"

@interface MDMainPreferencesViewController : NSViewController  <RHPreferencesViewControllerProtocol, NSNetServiceBrowserDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate> {
}
@property IBOutlet NSTableView *tableView;
@property IBOutlet NSTextField *addressTextField;
@property IBOutlet NSTextField *titleTextField;
@property IBOutlet NSTextField *serverAddressLabel;

@property IBOutlet NSTextField *tokenLabel;
@property IBOutlet NSTextField *tokenField;
@end
