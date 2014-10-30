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
@end

@implementation MDIOSDevelopersDeviceListViewController
@synthesize isLoading=_isLoading;
- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];

    
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    
    self.tableView.tableHeaderView = searchBar;
    
    self.isLoading = YES;
    [[MDDSSManager defaultManager] getAllDevices:^(NSDictionary *json, NSError *error) {
        self.devices = [json objectForKey:@"result"];
        self.resultData = [self.devices mutableCopy];
        self.isLoading = NO;
        [self.tableView reloadData];
    }];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.resultData removeAllObjects];
    for(NSDictionary *dict in self.resultData)
    {
        if([[dict objectForKey:@"name"] containsString:searchString])
        {
            [self.resultData addObject:dict];
        }
    }
    return YES;
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
    return self.resultData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"propertyCell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"propertyCell"];
    }
    
    NSDictionary *data = [self.resultData objectAtIndex:indexPath.row];
    cell.textLabel.text = [data objectForKey:@"name"];
    cell.detailTextLabel.text = [data objectForKey:@"meterName"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MDIOSDevicesViewController *controller = [sb instantiateViewControllerWithIdentifier:@"Device"];
    controller.device = [self.resultData objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}
@end
