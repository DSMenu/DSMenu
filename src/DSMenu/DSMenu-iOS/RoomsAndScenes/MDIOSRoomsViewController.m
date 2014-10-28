//
//  DMControlViewController.m
//  dSMetering
//
//  Created by Jonas Schnelli on 10.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSRoomsViewController.h"
#import "MDIOSRoomTableViewCell.h"
#import "MDDSSManager.h"
#import "MDDSHelper.h"

@interface MDIOSRoomsViewController ()
@property NSMutableArray *zones;
@property NSDictionary *displayedJSON;
@end

@implementation MDIOSRoomsViewController
@synthesize isLoading=_isLoading;
@synthesize noConnection=_noConnection;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"roomsTitle", @"");
    
    self.zones = [NSMutableArray array];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTable:) name:kDS_STRUCTURE_DID_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoading) name:kDS_START_LOADING_STRUCTURE object:nil];
    
    [self showLoading];
    
    [self recheckConnection];
    [self updateTable:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.isLoading == NO && (!self.zones || self.zones.count <= 0))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDS_SHOULD_TRY_TO_RELOAD_STRUCTURE object:nil];
    }
}

- (void)showLoading
{
    self.isLoading = YES;
    
    if(self.zones.count <= 0 && !self.selectWidgetMode && !self.noConnection)
    {
        [self.navigationItem setPrompt:NSLocalizedString(@"loading", @"loading in rooms table")];
    }
}

- (void)recheckConnection
{
    if([MDDSSManager defaultManager].connectionProblems || [MDDSSManager defaultManager].host == nil || [MDDSSManager defaultManager].host.length <= 1)
    {
        self.noConnection = YES;
        self.isLoading = NO;
        [self showNoEntriesViewWithText:NSLocalizedString(@"noConnectionToYourDSS", @"")];
        if(!self.selectWidgetMode)
        {
            self.navigationItem.prompt = nil;
        }
    }
    else
    {
        [self hideNoEntriesView];
        self.noConnection = NO;
    }
    [self.tableView reloadData];
}

- (void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
    UIActivityIndicatorView *wheel = (UIActivityIndicatorView *)self.navigationItem.rightBarButtonItem.customView;
    if(isLoading)
    {
        [wheel startAnimating];
    }
    else
    {
        [wheel stopAnimating];
    }
}

- (BOOL)isLoading
{
    return _isLoading;
}

- (void)setNoConnection:(BOOL)noConnection
{
    _noConnection = noConnection;
}

- (BOOL)noConnection
{
    return _noConnection;
}

- (void)updateTable:(NSNotification *)notification
{
    [self recheckConnection];
    
    NSDictionary *json = nil;
    
    if(!self.selectWidgetMode)
    {
        self.navigationItem.prompt = nil;
    }
    
    if(notification)
    {
        json = notification.object;
        self.isLoading = NO;
        
        if(self.zones.count > 0 && ![MDDSHelper shouldRefreshStructure:json oldStructure:self.displayedJSON])
        {
            return;
        }
    }
    else
    {
        json = [MDDSSManager defaultManager].lastLoadesStructure;
        
    }
    
    if(!json)
    {
        // don't build table if there are no data
        return;
    }
    
    self.displayedJSON = json;
    self.zones = [NSMutableArray array];
    
    //sort zones
    NSArray *zones = [[[json objectForKey:@"result"] objectForKey:@"apartment"] objectForKey:@"zones"];
    zones = [zones sortedArrayUsingComparator:^(id obj1, id obj2) {
        if(![obj1 objectForKey:@"name"] || [[obj1 objectForKey:@"name"] length] <= 0)
        {
            return NSOrderedDescending;
        }
        else if(![obj2 objectForKey:@"name"] || [[obj2 objectForKey:@"name"] length] <= 0)
        {
            return NSOrderedAscending;
        }
        return [[obj1 objectForKey:@"name"] compare:[obj2 objectForKey:@"name"]];
    }];
    
    // build zone menus
    for(NSDictionary *zoneDict in zones)
    {
        if([[zoneDict objectForKey:@"id"] intValue] == 0)
        {
            // logical ID 0 room
            continue;
        }
        
        [self.zones addObject:zoneDict];
    }
    
    [self.roomsTable reloadData];
}


#pragma mark UITableView stack
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.noConnection)
    {
        return 1;
    }
    return self.zones.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.noConnection)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.textLabel.text = NSLocalizedString(@"No Connection To Your DSS...", @"");
        return cell;
    }
    static NSString *CellIdentifier = @"RoomCell";
    MDIOSRoomTableViewCell *cell = (MDIOSRoomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[MDIOSRoomTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *zoneDict = [self.zones objectAtIndex:indexPath.row];
    
    NSString *roomName = [zoneDict objectForKey:@"name"];
    if(roomName.length <= 0)
    {
        // define unnamed room
        roomName = [NSLocalizedString(@"unnamedRoom", @"Menu String for unnamed room") stringByAppendingFormat:@" %@", [zoneDict objectForKey:@"id"]];
    }
    
    [cell buildLabels:[MDDSHelper availableGroupsForZone:zoneDict]];
    
    cell.zoneId = [zoneDict objectForKey:@"id"];
    cell.mainLabel.text = roomName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MDIOSScenesTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Scenes"];
    if(self.selectWidgetMode)
    {
        controller.navigationItem.prompt = self.navigationItem.prompt;
        controller.delegate = self.delegate;
        controller.selectWidgetMode = YES;
    }
    controller.zoneDict = [self.zones objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}
@end
