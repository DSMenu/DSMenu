//
//  MDIOSSettingsConnectionsViewController.h
//  DSMenu
//
//  Created by Jonas Schnelli on 20.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDIOSSettingsConnectionsViewController : UITableViewController <NSNetServiceBrowserDelegate, UITextFieldDelegate>
@property (assign) BOOL showLocalConnection;
@property (assign) BOOL searchingMDNS;
@property (assign) BOOL tryToConnect;
@property (assign) BOOL tryToConnectLocal;
@property (assign) BOOL checkConnection;
@property (assign) BOOL connectionError;
@property (assign) BOOL connectionErrorLocal;


@property (strong) NSString *currentUsername;
@property (strong) NSString *currentPassword;
@property (strong) NSString *currentIPAddressOrHostname;

@property (strong) UITextField *passwordTextField;

@end
