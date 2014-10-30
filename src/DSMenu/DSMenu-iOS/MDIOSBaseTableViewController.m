//
//  MDIOSBaseTableViewController.m
//  DSMenu
//
//  Created by Jonas Schnelli on 23.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSBaseTableViewController.h"

@interface MDIOSBaseTableViewController ()

@end

@implementation MDIOSBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showNoEntriesViewWithText:(NSString *)text
{
    [self hideNoEntriesView];
    self.noEntriesView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.bounds.size.height)];
    self.noEntriesView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.noEntriesView];
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UILabel *noFavsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,10,self.view.bounds.size.width-20,self.view.bounds.size.height/2.0)];
    noFavsLabel.backgroundColor = [UIColor clearColor];
    noFavsLabel.text = text;
    noFavsLabel.font = [UIFont fontWithName:@"Helvetica Light" size:22];
    noFavsLabel.textColor = [UIColor lightGrayColor];
    noFavsLabel.numberOfLines = 10;
    noFavsLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.noEntriesView addSubview:noFavsLabel];
}

- (void)hideNoEntriesView
{
    self.tableView.scrollEnabled = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.noEntriesView removeFromSuperview];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
