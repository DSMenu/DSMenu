//
//  DMFirstViewController.m
//  dSMetering
//
//  Created by Jonas Schnelli on 11.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSConsumptionViewController.h"
#import "MDDSSConsumptionManager.h"
#import "MDDSSManager.h"
#import "MDIOSConsumptionTableViewCell.h"

@interface MDIOSConsumptionViewController ()
@property NSMutableArray *tableData;
@end

@implementation MDIOSConsumptionViewController

//-(UIStatusBarStyle)preferredStatusBarStyle{
//    return UIStatusBarStyleBlackOpaque;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"consumptionTitle", @"");
    
    [MDDSSConsumptionManager defaultManager].callbackHistory = ^(NSDictionary *values, NSArray *dSM){
        [self.consumptionView setNeedsDisplay];
    };
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kDS_CONSUMPTION_DID_CHANGE object:nil queue:nil usingBlock:^(NSNotification *notification){

        [self hideNoEntriesView];
        
        NSArray *consumptionData = notification.object;
        self.tableData = (NSMutableArray *)consumptionData;
        [self.consumptionTable reloadData];
    }];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self recheckConnection];
}

- (void)recheckConnection
{
    if([MDDSSManager defaultManager].connectionProblems || [MDDSSManager defaultManager].host == nil || [MDDSSManager defaultManager].host.length <= 1)
    {
        [self showNoEntriesViewWithText:NSLocalizedString(@"noConnectionToYourDSS", @"")];
    }
    else
    {
        [self hideNoEntriesView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self recheckConnection];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDS_SHOULD_START_POLLING_CONSUMPTION_DATA object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDS_SHOULD_STOP_POLLING_CONSUMPTION_DATA object:nil];
}

#pragma mark - UITableViewStack
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!self.tableData)
    {
        return 1;
    }
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MDIOSConsumptionTableViewCell *cell = (MDIOSConsumptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[MDIOSConsumptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(!self.tableData)
    {
        cell = [[MDIOSConsumptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.consumptionLabel.text = @"loading current consumption...";
        cell.consumptionLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.consumptionLabelBackgroundColor = [UIColor grayColor];
        //cell.backgroundSquare.hidden = YES;
        return cell;
    }
    cell.backgroundSquare.hidden = NO;
    
    //cell.backgroundColor = [UIColor blackColor];
    //cell.textLabel.textColor = [UIColor lightGrayColor];

    //cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.consumptionLabel.text = [NSString stringWithFormat:@"%@ W", [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"value"]];
    
    
    
    cell.textLabel.text = [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    if([[[self.tableData objectAtIndex:indexPath.row] objectForKey:@"name"] isEqualToString:@"all"])
    {
        cell.consumptionLabelBackgroundColor = [UIColor redColor];
        cell.textLabel.text = NSLocalizedString(@"Total", @"");
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    else
    {
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.consumptionLabelBackgroundColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.2 alpha:1.0];
    }
    
    [cell setNeedsLayout];
    
    return cell;
}

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dsmID = [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"dsid"];
    if(dsmID)
    {
        [MDDSSConsumptionManager defaultManager].filterHistoryWithDSMID = dsmID;
        [[MDDSSConsumptionManager defaultManager] invalidateHistory];
        [self.consumptionView setVisibleState:YES];
        [self.consumptionView setNeedsDisplay];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.consumptionView setNeedsDisplay];
}

@end
