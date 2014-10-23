//
//  MDIOSBaseTableViewController.h
//  DSMenu
//
//  Created by Jonas Schnelli on 23.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDIOSBaseTableViewController : UITableViewController
@property (strong) UIView *noEntriesView;
- (void)showNoEntriesViewWithText:(NSString *)text;
- (void)hideNoEntriesView;
@end
