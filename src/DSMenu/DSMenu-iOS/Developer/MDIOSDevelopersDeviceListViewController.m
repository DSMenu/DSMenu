//
//  MDIOSDevelopersDeviceListViewController.m
//  DSMenu
//
//  Created by Jonas Schnelli on 30.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSDevelopersDeviceListViewController.h"
#import "MDDSSManager.h"
#import "MDIOSDevicesViewController.h"

@interface MDIOSDevelopersDeviceListViewController ()
@property NSArray *devices;
@property NSMutableArray *resultData;
@property BOOL isLoading;
@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation MDIOSDevelopersDeviceListViewController
@synthesize isLoading=_isLoading;
- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    
    
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    
    
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
    
    self.isLoading = YES;
    [[MDDSSManager defaultManager] getAllDevices:^(NSDictionary *json, NSError *error) {
        self.devices = [json objectForKey:@"result"];
        self.resultData = [self.devices mutableCopy];
        self.isLoading = NO;
        [self.tableView reloadData];
    }];
}

#pragma mark - UISearchResultsUpdating



- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    NSString *searchString = [searchController.searchBar text];
    
    [self.resultData removeAllObjects];
    for(NSDictionary *dict in self.devices)
    {
        if([[dict objectForKey:@"name"] localizedCaseInsensitiveContainsString:searchString] || [[dict objectForKey:@"meterName"] localizedCaseInsensitiveContainsString:searchString] || [[dict objectForKey:@"hwInfo"] localizedCaseInsensitiveContainsString:searchString])
        {
            [self.resultData addObject:dict];
        }
    }
    
    [((UITableViewController *)searchController.searchResultsController).tableView reloadData];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)self.navigationItem.rightBarButtonItem.customView;
    
    if(_isLoading)
    {
        [activityIndicator startAnimating];
    }
    else
    {
        [activityIndicator stopAnimating];
    }
}

- (BOOL)isLoading
{
    return _isLoading;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        return [self.resultData count];
    } else {
        return [self.devices count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"propertyCell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"propertyCell"];
    }
    
    NSDictionary *data;
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        data = [self.resultData objectAtIndex:indexPath.row];
    } else {
        data = [self.devices objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = [data objectForKey:@"name"];
    cell.detailTextLabel.text = [data objectForKey:@"meterName"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MDIOSDevicesViewController *controller = [sb instantiateViewControllerWithIdentifier:@"Device"];
    
    NSDictionary *data;
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        data = [self.resultData objectAtIndex:indexPath.row];
    } else {
        data = [self.devices objectAtIndex:indexPath.row];
    }
    
    controller.device = data;
    [self.navigationController pushViewController:controller animated:YES];
}
@end
