//
//  DMFirstViewController.h
//  dSMetering
//
//  Created by Jonas Schnelli on 11.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

/**
 * \ingroup iOS
 */


#import <UIKit/UIKit.h>
#import "MDIOSConsumptionView.h"
#import "MDIOSBaseViewController.h"

/**
 *  MDIOSConsumptionTableViewCell
 *  view controller of the whole consumption screen
 */
@interface MDIOSConsumptionViewController : MDIOSBaseViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong) IBOutlet MDIOSConsumptionView *consumptionView;
@property (strong) IBOutlet UITableView *consumptionTable;
@end
