//
//  MDIOSSettingsWidgetViewController.h
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDIOSRoomsViewControllerDelegate.h"

@interface MDIOSSettingsWidgetViewController : UITableViewController <MDIOSRoomsViewControllerDelegate>
@property (strong) IBOutlet UITableViewCell *selectFavoritesCell;
@end
