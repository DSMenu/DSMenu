//
//  DMScenesTableViewController.m
//  dSMetering
//
//  Created by Jonas Schnelli on 10.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSScenesTableViewController.h"
#import "MDDSHelper.h"
#import "MDDSSManager.h"
#import "MDIOSScenePresetTableViewCell.h"
#import "MDIOSFavoritesManager.h"
#import "MDIOSDevicesViewController.h"

@interface MDIOSScenesTableViewController ()
@property NSMutableArray *sections;
@property NSDictionary *cellDictInEdit;
@end

@implementation MDIOSScenesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.5; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
    
    // set title
    self.title = [self.zoneDict objectForKey:@"name"];
    if(self.title.length <= 0)
    {
        // define unnamed room
        self.title = [NSLocalizedString(@"unnamedRoom", @"Menu String for unnamed room") stringByAppendingFormat:@" %@", [self.zoneDict objectForKey:@"id"]];
    }

    [self buildCells];
    
    if([[MDIOSFavoritesManager defaultManager] favoriteForZone:[(NSNumber *)[self.zoneDict objectForKey:@"id"] stringValue] group:nil scene:nil])
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ReviewSheetStarFull.png"] style:UIBarButtonItemStylePlain target:self action:@selector(favorite)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ReviewSheetStarEmptyNew.png"] style:UIBarButtonItemStylePlain target:self action:@selector(favorite)];
    }
}

- (void)buildCells
{
    self.sections = [NSMutableArray array];
    NSArray *buildGroups = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:2],[NSNumber numberWithInt:3],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5], nil];
    for(NSNumber *group in buildGroups)
    {
        
        int groupInt = [group intValue];
        if([MDDSHelper hasGroup:groupInt inZone:self.zoneDict])
        {
            
            NSMutableDictionary *section = [NSMutableDictionary dictionary];
            [section setObject:[NSMutableArray array] forKey:@"cells"];
            [section setObject:NSLocalizedString( ([NSString stringWithFormat:@"group%d",[group intValue]]) , @"") forKey:@"title"];
            
            
            
            
            // check is there are possible areas
            NSMutableArray *areas       = [[NSMutableArray alloc] init];
            NSMutableArray *areaItems   = [[NSMutableArray alloc] init];
            
            NSMutableArray *upperScenes       = [[NSMutableArray alloc] init];
            for(NSDictionary *device in [self.zoneDict objectForKey:@"devices"])
            {
                if([[device objectForKey:@"buttonActiveGroup"] intValue] == groupInt && [[device objectForKey:@"buttonID"] intValue] > 0 && [[device objectForKey:@"buttonID"] intValue] < 4)
                {
                    [areas addObject:[device objectForKey:@"buttonID"]];
                }
                
                if([[device objectForKey:@"buttonActiveGroup"] intValue] == groupInt && [[device objectForKey:@"buttonID"] intValue] > 5)
                {
                    // high scene presets possible
                    
                    int offset = [[device objectForKey:@"buttonID"] intValue]-6;
                    
                    [upperScenes addObject:[NSNumber numberWithInt:32+(offset*2)]];
                    [upperScenes addObject:[NSNumber numberWithInt:33+(offset*2)]];
                    [upperScenes addObject:[NSNumber numberWithInt:20+(offset*3)]];
                    [upperScenes addObject:[NSNumber numberWithInt:21+(offset*3)]];
                    [upperScenes addObject:[NSNumber numberWithInt:22+(offset*3)]];
                }
            }
            
            // load custom scene names
            NSArray *customSceneNames = [[MDDSSManager defaultManager] customSceneNamesForGroup:groupInt inZone:[[self.zoneDict objectForKey:@"id"] intValue]];
            if(customSceneNames)
            {
                DDLogVerbose(@"found custom scene name: %@ for %d", customSceneNames, groupInt);
            }
            
            int scenes[] = {0,5,6,7,8,9,15,17,18,19,32,33,20,21,22,34,35,23,24,25,36,37,26,27,28,38,39,29,30,31};
            
            for(int arrayIndex=0;arrayIndex<sizeof(scenes) / sizeof(int);arrayIndex++)
            {
                int i = scenes[arrayIndex];
                if((i==15 && groupInt != 2) || (i>19 && [upperScenes indexOfObject:[NSNumber numberWithInt:i]] == NSNotFound))
                {
                    continue;
                }
                
                if(i == 32 || i == 34 || i == 36 || i == 38)
                {
                    NSDictionary *cellDict = @{ @"title": @"-", @"tag" : @""};
                    [(NSMutableArray *)[section objectForKey:@"cells"] addObject:cellDict];
                }
                NSString *customName = [MDDSHelper customSceneNameForScene:i fromJSON:customSceneNames];
                NSString *i18nLabel = [NSString stringWithFormat:@"group%dscene%d", groupInt, i];
                if(i>19 && [upperScenes indexOfObject:[NSNumber numberWithInt:i]] != NSNotFound && (i!=32 && i!=34 && i!=36 && i!=38) )
                {
                    i18nLabel = [NSString stringWithFormat:@"groupXscene%d", i];
                }
                NSString *sceneTitle = NSLocalizedString(i18nLabel, @"Zone Submenu Scene X Item");
                if(customName.length > 0)
                {
                    DDLogVerbose(@"%@", self.zoneDict);
                    sceneTitle = [[sceneTitle stringByAppendingString:@" - "] stringByAppendingString:customName];
                }
                
                
                UIImage *img = (( i == 0) ? [UIImage imageNamed:@"off_menu_icon"] : [UIImage imageNamed:[NSString stringWithFormat:@"group_%d", groupInt]]);
                if(img == nil)
                {
                    img = [UIImage imageNamed:@"off_menu_icon"];
                }
                if(!sceneTitle) {
                    // double secure nil into dictionaries
                    sceneTitle = @"unknown";
                }
                
                if(!customName)
                {
                    customName = @"";
                }
                NSDictionary *cellDict = @{ @"title": sceneTitle, @"tag" : [NSNumber numberWithInt:i], @"group": [NSNumber numberWithInt:groupInt], @"image" : img, @"customName": customName};
                
                
                // Area Scenes
                if( (i==6 || i==7 || i==8 || i==9 ) )
                {
                    // only add if the area is present
                    if(([areas indexOfObjectIdenticalTo:[NSNumber numberWithLong:(long)(i-5)]] != NSNotFound))
                    {
                        
                        [areaItems addObject:cellDict];
                        
                        NSString *customName = [MDDSHelper customSceneNameForScene:i-5 fromJSON:customSceneNames]; //-5 for area off scene (check ds_basic.pdf)
                        NSString *i18nLabel = [NSString stringWithFormat:@"group%dscene%d", groupInt, i-5];
                        NSString *sceneTitle = NSLocalizedString(i18nLabel, @"Zone Submenu Scene X Item");
                        if(customName.length > 0)
                        {
                            sceneTitle = [[sceneTitle stringByAppendingString:@" - "] stringByAppendingString:customName];
                        }
                        
                        
                        UIImage *img = (( i == 0) ? [UIImage imageNamed:@"off_menu_icon"] : [UIImage imageNamed:[NSString stringWithFormat:@"group_%d", groupInt]]);
                        if(img == nil)
                        {
                            img = [UIImage imageNamed:@"off_menu_icon"];
                        }
                        NSDictionary *areaCellDict = @{ @"title": sceneTitle, @"tag" : [NSNumber numberWithInt:i-5], @"group": [NSNumber numberWithInt:groupInt], @"image" : img};
                        
                        [areaItems addObject:areaCellDict];
                    }
                }
                else
                {
                    [(NSMutableArray *)[section objectForKey:@"cells"] addObject:cellDict];
                }
            }
            
            //            if(groupInt == 1)
            //            {
            //                // show dimming
            //                MDStepMenuItem *stepMenuItem = [[MDStepMenuItem alloc] init];
            //                stepMenuItem.stepTarget = aTarget;
            //                stepMenuItem.groupId = groupInt;
            //                stepMenuItem.zoneId = item.zoneId;
            //                [item.submenu addItem:stepMenuItem];
            //            }
            //
            // add area items at bottom
            for(NSDictionary *areaItem in areaItems)
            {
                [(NSMutableArray *)[section objectForKey:@"cells"] addObject:areaItem];
            }
            ////////////////////////
            
            [self.sections addObject:section];
            
        }
        
        
    }
    //
    //    // Deep Off
    //    MDSceneMenuItem *deepOffScene = [[MDSceneMenuItem alloc] initWithTitle:NSLocalizedString(@"deeopOffSceneItem", @"Zone Submenu Scene X Item") action:@selector(sceneMenuItemClicked:) keyEquivalent:@""];
    //    deepOffScene.target = item;
    //    deepOffScene.tag = 68;
    //    deepOffScene.group = 1;
    //    deepOffScene.image = [NSImage imageNamed:@"group_2"];
    //    [item.submenu addItem:deepOffScene];
    //
    
    NSMutableDictionary *section = [NSMutableDictionary dictionary];
    [section setObject:[NSMutableArray array] forKey:@"cells"];
    [section setObject:NSLocalizedString( @"specialMenu" , @"") forKey:@"title"];
    
    NSDictionary *deepOffDict = @{ @"title": NSLocalizedString(@"deeopOffSceneItem",@""),  @"tag" : [NSNumber numberWithInt:68], @"group": [NSNumber numberWithInt:1], @"image" : [UIImage imageNamed:@"group_2"]};
    
    [section setObject:[NSArray arrayWithObject:deepOffDict] forKey:@"cells"];
    [self.sections addObject:section];
    
    // Devices Menu
    
    section = [NSMutableDictionary dictionary];
    [section setObject:[NSMutableArray array] forKey:@"cells"];
    [section setObject:NSLocalizedString( @"devicesSection" , @"") forKey:@"title"];
    
    NSArray *devices = [self.zoneDict objectForKey:@"devices"];
    BOOL shouldShowDeviceMenu = NO;
    for(NSDictionary *device in devices)
    {
        if([[device objectForKey:@"groups"] count] == 1 && [[device objectForKey:@"groups"] indexOfObjectIdenticalTo:[NSNumber numberWithLong:(long)8]] != NSNotFound)
        {
            shouldShowDeviceMenu = YES;
        }
    }
    
    
    
    // sort the devices A-Z
    devices = [devices sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj1 objectForKey:@"name"] compare:[obj2 objectForKey:@"name"]];
    }];
    
    for(NSDictionary *device in devices)
    {
        if([[device objectForKey:@"outputMode"] intValue] == 0)
        {
            continue;
        }
        
        NSString *group = @"0";
        if([device objectForKey:@"groups"])
        {
            for(NSNumber *groupNum in [device objectForKey:@"groups"])
            {
                group = [groupNum stringValue];
                break;
            }
        }
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"group_%d", [group intValue]]];
        if(img == nil)
        {
            img = [UIImage imageNamed:@"off_menu_icon"];
        }
        NSDictionary *cellDict = @{ @"device": device, @"title": [device objectForKey:@"name"], @"tag" : @"5", @"dsid" : [device objectForKey:@"id"], @"group": group, @"image" : img};
        
        [(NSMutableArray *)[section objectForKey:@"cells"] addObject:cellDict];
    }
    
    [self.sections addObject:section];
}

- (void)favorite
{
    self.isFavorite = !self.isFavorite;

    MDIOSFavorite *favorite = [[MDIOSFavorite alloc] init];
    favorite.zone   = [(NSNumber *)[self.zoneDict objectForKey:@"id"] stringValue];
    favorite.group  = nil;
    favorite.scene  = nil;
    favorite.favoriteType = MDIOSFavoriteTypeZone;

    UIImage *favStar = nil;
    if(self.isFavorite)
    {
        favStar = [UIImage imageNamed:@"ReviewSheetStarFull.png"];
        [[MDIOSFavoritesManager defaultManager] addFavorit:favorite];
    }
    else
    {
        favStar = [UIImage imageNamed:@"ReviewSheetStarEmptyNew.png"];
        [[MDIOSFavoritesManager defaultManager] removeFavorite:favorite];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:favStar style:UIBarButtonItemStylePlain target:self action:@selector(favorite)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.sections objectAtIndex:section] objectForKey:@"title"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[self.sections objectAtIndex:section] objectForKey:@"cells"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    MDIOSScenePresetTableViewCell *cell = (MDIOSScenePresetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[MDIOSScenePresetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *cellDict = [[[self.sections objectAtIndex:indexPath.section] objectForKey:@"cells"] objectAtIndex:indexPath.row];
    if([[cellDict objectForKey:@"title"] isEqualToString:@"-"])
    {
        UITableViewCell *cell2 = [[UITableViewCell alloc] init];
        cell = (MDIOSScenePresetTableViewCell *)cell2;
        cell.textLabel.text = @"  ";
        cell.imageView.image = [UIImage imageNamed:@"group_1.png"];
        cell.imageView.contentMode = UIViewContentModeTopLeft;
        cell.imageView.alpha = 0.0;
        cell.separatorInset = UIEdgeInsetsMake(0.f, 47.f, 0.f, 0.0f);
        cell.alpha = 0.8;
    }
    else
    {
        cell.textLabel.text = [cellDict objectForKey:@"title"];
        cell.imageView.image = [cellDict objectForKey:@"image"];
        
        cell.group = [cellDict objectForKey:@"group"];
        cell.scene = [cellDict objectForKey:@"tag"];
        cell.zone = [self.zoneDict objectForKey:@"id"];
        
        [cell checkFavoriteState];
        
        if([cellDict objectForKey:@"device"])
        {
            cell.favorizeButton.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            cell.favorizeButton.hidden = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
  
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellDict = [[[self.sections objectAtIndex:indexPath.section] objectForKey:@"cells"] objectAtIndex:indexPath.row];
    if([[cellDict objectForKey:@"title"] isEqualToString:@"-"])
    {
        return 10.0;
    }
    
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.selectWidgetMode)
    {
        
        MDIOSWidgetAction *action = [[MDIOSWidgetAction alloc] init];
        NSDictionary *cellDict = [[[self.sections objectAtIndex:indexPath.section] objectForKey:@"cells"] objectAtIndex:indexPath.row];
        action.group = [cellDict objectForKey:@"group"];
        action.scene = [cellDict objectForKey:@"tag"];
        action.zone = [self.zoneDict objectForKey:@"id"];
        action.title = [NSString stringWithFormat:@"%@ %@ - %@",
                                NSLocalizedString(([NSString stringWithFormat:@"group%@", action.group]), @""),
                              NSLocalizedString(([NSString stringWithFormat:@"group%@scene%@", action.group, action.scene]), @""),
                                [self.zoneDict objectForKey:@"name"] ];
        [self.delegate roomsOrScenesViewController:self didSelectAction:action];
        return;
    }
    
    NSDictionary *cellDict = [[[self.sections objectAtIndex:indexPath.section] objectForKey:@"cells"] objectAtIndex:indexPath.row];
    NSLog(@"%@", cellDict);
    
    if([cellDict objectForKey:@"device"])
    {
        MDIOSDevicesViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Device"];
        controller.device = [cellDict objectForKey:@"device"];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        MDIOSScenePresetTableViewCell *cell = (MDIOSScenePresetTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.isLoading = YES;
        
        [[MDDSSManager defaultManager] callScene:[cellDict objectForKey:@"tag"] zoneId:[self.zoneDict objectForKey:@"id"] groupID:[cellDict objectForKey:@"group"] callback:^(NSDictionary *json, NSError *error)
         {
             cell.isLoading = NO;
         }];
    }
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
        
        // show alert with input
        NSDictionary *cellDict = [[[self.sections objectAtIndex:indexPath.section] objectForKey:@"cells"] objectAtIndex:indexPath.row];
        
        NSString *text = [NSString stringWithFormat:(NSLocalizedString(@"changeSceneNameTextFormat", @"")), [cellDict objectForKey:@"title"]];
        NSString *currentText = [cellDict objectForKey:@"customName"];
        if([cellDict objectForKey:@"device"])
        {
            text = [NSString stringWithFormat:(NSLocalizedString(@"changeDeviceNameTextFormat", @"")), [cellDict objectForKey:@"title"]];
            
            currentText = [[cellDict objectForKey:@"device"] objectForKey:@"name"];
        }
        else
        {
            if([[cellDict objectForKey:@"tag"] intValue] >= 64)
            {
                return;
            }
        }
        
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"changeNameTitle", @"") message:text delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Ok", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *sceneText = [alert textFieldAtIndex:0];
        sceneText.text = currentText;
        [alert show];
        self.cellDictInEdit = cellDict;
        
    } else {
        NSLog(@"gestureRecognizer.state = %ld", gestureRecognizer.state);
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {  //Login
        UITextField *newSceneName = [alertView textFieldAtIndex:0];
        
        // only store name if name is different
        if(![newSceneName.text isEqualToString:[self.cellDictInEdit objectForKey:@"customName"]])
         {
             
             
             UIBarButtonItem *oldRightItem = self.navigationItem.rightBarButtonItem;
             UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
             self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
             [activityIndicator startAnimating];
             
             if([self.cellDictInEdit objectForKey:@"device"])
             {
                 // device type
                 if([[self.cellDictInEdit objectForKey:@"device"] objectForKey:@"id"])
                 {
                     [[MDDSSManager defaultManager] saveDeviceName:newSceneName.text dsid:[[self.cellDictInEdit objectForKey:@"device"] objectForKey:@"id"] callback:^(NSDictionary *json, NSError *error) {
                         
                         
                         //could be faster if we would load only the zone (property/get) and not the whole structure
                         [[MDDSSManager defaultManager] getStructure:^(NSDictionary *jsonSceneNames, NSError *error) {
                             @try {
                                 for(NSDictionary *aZoneDict in [[[[MDDSSManager defaultManager].lastLoadesStructure objectForKey:@"result"] objectForKey:@"apartment"] objectForKey:@"zones"])
                                 {
                                     if([[aZoneDict objectForKey:@"id"] isEqual:[self.zoneDict objectForKey:@"id"]])
                                     {
                                         self.zoneDict = aZoneDict;
                                         break;
                                     }
                                 }
                                 [self buildCells];
                             }
                             @catch (NSException *exception) {
                                 
                             }
                             @finally {
                                 
                             }
                             [activityIndicator stopAnimating];
                             self.navigationItem.rightBarButtonItem = oldRightItem;
                             [self.tableView reloadData];
                         }];
                     }];
                 }
                 else
                 {
                     [activityIndicator stopAnimating];
                 }
             }
             else
             {
                 // scene type
                 [[MDDSSManager defaultManager] saveSceneName:newSceneName.text zone:[self.zoneDict objectForKey:@"id"] scene:[self.cellDictInEdit objectForKey:@"tag"] group:[self.cellDictInEdit objectForKey:@"group"] callback:^(NSDictionary *json, NSError *error) {
                     
                     [[MDDSSManager defaultManager] getCustomSceneNames:^(NSDictionary *jsonSceneNames, NSError *error) {
                         [self buildCells];
                         [activityIndicator stopAnimating];
                         self.navigationItem.rightBarButtonItem = oldRightItem;
                         [self.tableView reloadData];
                     }];
                 }];
            }
         }
    }
    
    self.cellDictInEdit = nil;
}

@end
