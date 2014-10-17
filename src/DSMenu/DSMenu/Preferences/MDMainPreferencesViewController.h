//
//  RHAboutViewController.h
//  RHPreferencesTester
//

/**
 * \ingroup OSX
 */

#import <Cocoa/Cocoa.h>
#import "RHPreferences.h"

@interface MDMainPreferencesViewController : NSViewController  <RHPreferencesViewControllerProtocol, NSNetServiceBrowserDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate> {
}
@property IBOutlet NSTableView *tableView;
@property IBOutlet NSTabView *tabView;
@property IBOutlet NSTextField *addressTextField;
@property IBOutlet NSTextField *titleTextField;
@property IBOutlet NSTextField *serverAddressLabel;
@property IBOutlet NSButton *manualIPCheckbox;

@property IBOutlet NSTextField *tokenLabel;
@property IBOutlet NSTextField *tokenField;
@property IBOutlet NSProgressIndicator *progressIndicator;

@property IBOutlet NSProgressIndicator *remoteConnectivityProgressIndicator;
@property IBOutlet NSButton *loginButton;
@property IBOutlet NSTextField *remoteConnectivityUsernameField;
@property IBOutlet NSTextField *remoteConnectivityPasswordField;

@property IBOutlet NSTextField *remoteConnectivityPasswordLabel;
@property IBOutlet NSTextField *remoteConnectivityUsernameLabel;

@property IBOutlet NSImageView *remoteConnectivityStateImage;

@property IBOutlet NSTextField *remoteConnectivityStateText;
@property IBOutlet NSButton *remoteConnectivityDisconnectButton;
@property IBOutlet NSButton *remoteConnectivityLoginButton;


@property (assign) BOOL manualIP;
@end
