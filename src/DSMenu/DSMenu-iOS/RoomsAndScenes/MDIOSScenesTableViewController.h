//
//  DMScenesTableViewController.h
//  dSMetering
//
//  Created by Jonas Schnelli on 10.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

/**
 * \ingroup iOS
 */

#import <UIKit/UIKit.h>
#import "MDIOSRoomsViewControllerDelegate.h"

/**
 *  MDIOSConsumptionTableViewCell
 *  scenes table view controller
 */
@interface MDIOSScenesTableViewController : UITableViewController
@property (strong) NSDictionary *zoneDict;
@property (strong) id <MDIOSRoomsViewControllerDelegate> delegate;
@property (assign) BOOL selectWidgetMode;
@property (assign) BOOL isFavorite;
@end
