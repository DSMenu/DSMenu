//
//  DMFirstViewController.h
//  dSMetering
//
//  Created by Jonas Schnelli on 11.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDIOSConsumptionView.h"

@interface MDIOSConsumptionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong) IBOutlet MDIOSConsumptionView *consumptionView;
@property (strong) IBOutlet UITableView *consumptionTable;
@property (strong) IBOutlet UIView *noConnectionView;
@end
