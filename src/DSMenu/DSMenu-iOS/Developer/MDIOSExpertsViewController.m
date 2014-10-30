//
//  MDIOSExpertsViewController.m
//  DSMenu
//
//  Created by Jonas Schnelli on 30.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSExpertsViewController.h"
#import "MDIOSDeveloperTreeViewController.h"
#import "MDIOSDevelopersDeviceListViewController.h"

@interface MDIOSExpertsViewController ()

@end

@implementation MDIOSExpertsViewController

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

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0)
    {
        MDIOSDeveloperTreeViewController *treeController = [[MDIOSDeveloperTreeViewController alloc] init];
        treeController.path = @"/";
        [self.navigationController pushViewController:treeController animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if(indexPath.row == 1)
    {
        MDIOSDevelopersDeviceListViewController *devicesController = [[MDIOSDevelopersDeviceListViewController alloc] init];
        [self.navigationController pushViewController:devicesController animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
