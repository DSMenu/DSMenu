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
    [self.noEntriesView removeFromSuperview];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
