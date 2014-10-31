//
//  DMControlViewController.m
//  dSMetering
//
//  Created by Jonas Schnelli on 10.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

//UIPopover+Iphone.h
@interface UIPopoverController (overrides)
+ (BOOL)_popoversDisabled;
@end

//UIPopover+Iphone.m
@implementation UIPopoverController (overrides)
+ (BOOL)_popoversDisabled { return NO;
}
@end

#import "MDIOSRoomsViewController.h"
#import "MDIOSRoomTableViewCell.h"
#import "MDDSSManager.h"
#import "MDDSHelper.h"
#import "MDIOSFavoritesManager.h"
#import "MDIOSPopoverViewController.h"
#import "MDIOSPopoverNavigationController.h"

@interface MDIOSRoomsViewController ()
@property NSMutableArray *zones;
@property NSDictionary *displayedJSON;
@property NSDictionary *zoneDictInEdit;
@property (nonatomic, retain) UIPopoverController *generalActionsPopover;
@end

@implementation MDIOSRoomsViewController
@synthesize isLoading=_isLoading;
@synthesize noConnection=_noConnection;

- (void)viewDidLoad {
    [super viewDidLoad];

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.5; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
    
    self.title = NSLocalizedString(@"roomsTitle", @"");
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    self.zones = [NSMutableArray array];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTable:) name:kDS_STRUCTURE_DID_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoading) name:kDS_START_LOADING_STRUCTURE object:nil];
    
    [self recheckConnection];
    [self updateTable:nil];
}

- (void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
    
    if(_isLoading)
    {
        [self.refreshControl beginRefreshing];
    }
    else
    {
        [self.refreshControl endRefreshing];
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)self.navigationItem.rightBarButtonItem.customView;
        [activityIndicator stopAnimating];
    }
}

- (BOOL)isLoading
{
    return _isLoading;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.isLoading == NO && (!self.zones || self.zones.count <= 0))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDS_SHOULD_TRY_TO_RELOAD_STRUCTURE object:nil];
    }
    
    if(self.isLoading)
    {
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)self.navigationItem.rightBarButtonItem.customView;
        [activityIndicator startAnimating];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.refreshControl endRefreshing];
}

- (void)refresh
{
    [self showLoading];
    [[MDDSSManager defaultManager] getStructureWithCustomSceneNames:^(NSDictionary *json, NSError *error){
        [[NSNotificationCenter defaultCenter] postNotificationName:kDS_STRUCTURE_DID_CHANGE object:json];
        self.isLoading = NO;
    }];
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
    self.isLoading = NO;
    
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
    
    if([[MDIOSFavoritesManager defaultManager] favoriteForZone:[(NSNumber *)[zoneDict objectForKey:@"id"] stringValue] group:nil scene:nil])
    {
        [cell favorite:[NSNumber numberWithBool:YES]];
    }
    else
    {
        [cell favorite:[NSNumber numberWithBool:NO]];
    }
    
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

#pragma mark - popover stack

- (IBAction)showGeneralActions:(id)sender
{
    MDIOSPopoverViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Popover"];
    controller.modalPresentationStyle  = UIModalPresentationPopover;
    controller.popoverPresentationController.delegate = self;
    
    MDIOSPopoverNavigationController *navCtrl = [[MDIOSPopoverNavigationController alloc] initWithRootViewController:controller];
    
    navCtrl.modalPresentationStyle  = UIModalPresentationPopover;
    navCtrl.popoverPresentationController.delegate = self;
    
    UIPopoverController *pC = [[UIPopoverController alloc] initWithContentViewController:navCtrl];
    [pC presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

#pragma mark UIGesture stack

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press on table view at row %ld", indexPath.row);
        
        NSDictionary *zoneDict = [self.zones objectAtIndex:indexPath.row];
        
        NSString *text = [NSString stringWithFormat:(NSLocalizedString(@"changeZoneNameTextFormat", @"")), [zoneDict objectForKey:@"name"]];
        UIAlertView *alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"changeNameTitle", @"") message:text delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Ok", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *sceneText = [alert textFieldAtIndex:0];
        sceneText.text = [zoneDict objectForKey:@"name"];
        [alert show];
        self.zoneDictInEdit = zoneDict;
        
    } else {
        NSLog(@"gestureRecognizer.state = %ld", gestureRecognizer.state);
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {  //Login
        UITextField *newZoneName = [alertView textFieldAtIndex:0];
        
        // only store name if name is different
        if(![newZoneName.text isEqualToString:[self.zoneDictInEdit objectForKey:@"name"]])
        {
            UIBarButtonItem *oldRightItem = self.navigationItem.rightBarButtonItem;
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
            [activityIndicator startAnimating];
            
            // scene type
            [[MDDSSManager defaultManager] saveZoneName:newZoneName.text zoneId:[self.zoneDictInEdit objectForKey:@"id"] callback:^(NSDictionary *json, NSError *error) {
                
                self.zoneDictInEdit = nil;
                [[MDDSSManager defaultManager] getStructure:^(NSDictionary *jsonSceneNames, NSError *error) {
                    [activityIndicator stopAnimating];
                    self.navigationItem.rightBarButtonItem = oldRightItem;
                    [self updateTable:nil];
                }];
            }];
        }
    }
}

@end
