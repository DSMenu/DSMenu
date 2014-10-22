//
//  MDIOSSettingsViewController.h
//  DSMenu
//
//  Created by Jonas Schnelli on 20.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDIOSSettingsViewController : UITableViewController
@property (strong) IBOutlet UITableViewCell *connectionCell;
@property (strong) IBOutlet UITableViewCell *consumptionSettingsCell;
@property (strong) IBOutlet UITableViewCell *widgetSettingsCell;
@property (strong) IBOutlet UITableViewCell *expertSettingsCell;

@end
