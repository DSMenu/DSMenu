//
//  DMControlViewController.h
//  dSMetering
//
//  Created by Jonas Schnelli on 10.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

/**
 * \ingroup iOS
 */

#import <UIKit/UIKit.h>
#import "MDIOSScenesTableViewController.h"
#import "MDIOSRoomsViewControllerDelegate.h"
#import "MDIOSBaseTableViewController.h"

/**
 *  MDIOSConsumptionTableViewCell
 *  view controller of the iOS rooms screen
 */
@interface MDIOSRoomsViewController : MDIOSBaseTableViewController <UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate>
@property (strong) IBOutlet UITableView *roomsTable;
@property (strong) IBOutlet MDIOSScenesTableViewController *sceneViewController;
@property (assign) BOOL isLoading;
@property (assign) BOOL noConnection;
@property (assign) BOOL selectWidgetMode;
@property (strong) id <MDIOSRoomsViewControllerDelegate> delegate;
@end
