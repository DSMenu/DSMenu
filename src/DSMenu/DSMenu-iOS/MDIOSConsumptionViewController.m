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
    
    self.title = NSLocalizedString(@"Consumption", @"");

//    self.consumptionView = [[DMConsumptionView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height-100)];
//    [self.view addSubview:self.consumptionView];
    
    //[MDDSSConsumptionManager defaultManager].paddingRect = CGRectMake(0,0,0,0);
    //[MDDSSConsumptionManager defaultManager].padding = CGRectMake(0,0,0,0);
    //[MDDSSConsumptionManager defaultManager].backgroundColor = [UIColor colorWithRed:0.01 green:0.0 blue:0.0 alpha:1.0].CGColor;
//    [MDDSSConsumptionManager defaultManager].lineColor = [UIColor colorWithRed:0.81 green:0.82 blue:0.83 alpha:1.0].CGColor;
//    [MDDSSConsumptionManager defaultManager].fillColor = [UIColor colorWithRed:0.33 green:0.32 blue:0.31 alpha:0.5].CGColor;
    [MDDSSConsumptionManager defaultManager].callbackHistory = ^(NSDictionary *values, NSArray *dSM){
        [self.consumptionView setNeedsDisplay];
    };
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kDS_CONSUMPTION_DID_CHANGE object:nil queue:nil usingBlock:^(NSNotification *notification){

        NSArray *consumptionData = notification.object;
        self.tableData = (NSMutableArray *)consumptionData;
        
        [self.consumptionTable reloadData];
    }];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    //self.consumptionTable.backgroundColor = [UIColor blackColor];
    
    
    [self recheckConnection];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recheckConnection) name:kMD_NOTIFICATION_APPTOKEN_DID_CHANGE object:nil];
}

- (void)recheckConnection
{
    self.noConnectionView.hidden = YES;
    
    if([MDDSSManager defaultManager].connectionProblems || [MDDSSManager defaultManager].host == nil || [MDDSSManager defaultManager].host.length <= 1)
    {
        self.noConnectionView.hidden = NO;
    }
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
