//
//  DMSecondViewController.h
//  dSMetering
//
//  Created by Jonas Schnelli on 11.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

/**
 * \ingroup iOS
 */


#import <UIKit/UIKit.h>

/**
 *  MDIOSConsumptionTableViewCell
 *  view controller of the iOS settings screen
 */
@interface MDIOSSettingsConnectionViewController : UIViewController <UITextFieldDelegate, NSNetServiceBrowserDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong) IBOutlet UITextField *emailField;
@property (strong) IBOutlet UITextField *passwordField;
@property (strong) IBOutlet UISegmentedControl *connectionTypeSegmentedControl;

@property (strong) IBOutlet UIActivityIndicatorView *networkActivityIndicator;
@property (strong) IBOutlet UILabel *connectionStateInfoText;
@property (strong) IBOutlet UIImageView *statusImage;
@property (strong) IBOutlet UIButton *connectButton;
@property (strong) IBOutlet UIButton *disconnectButton;

@property (strong) IBOutlet UIButton *connectLocalButton;
@property (strong) IBOutlet UILabel *selectHostLabel;
@property (strong) IBOutlet UILabel *useManualIPLabel;
@property (strong) IBOutlet UITableView *localHostMDNSList;
@property (strong) IBOutlet UITextField *manualIPField;
@property (strong) IBOutlet UISwitch *useManualIP;
@property (strong) IBOutlet UIActivityIndicatorView *localConnectionActivityIndicator;
@property (strong) IBOutlet UIImageView *localStatusImage;
@end
