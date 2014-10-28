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

@interface MDIOSScenesTableViewController ()
@property NSMutableArray *sections;
@end

@implementation MDIOSScenesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sections = [NSMutableArray array];
    
    self.title = [self.zoneDict objectForKey:@"name"];
    
   
    
    //item.clickType = MDZoneMenuItemClickTypeNotOfInterest;
    
    //[section setObject:[self.zoneDict objectForKey:@"name"] forKey:@"title"];
    //[section setObject:[self.zoneDict objectForKey:@"id"] forKey:@"id"];
    if(self.title.length <= 0)
    {
        // define unnamed room
        self.title = [NSLocalizedString(@"unnamedRoom", @"Menu String for unnamed room") stringByAppendingFormat:@" %@", [self.zoneDict objectForKey:@"id"]];
    }
  
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
            for(int i=0;i<=39;i++)
            {
                if(i==0 || i==5 || i==6 || i==7 || i==8 || i==9 || i==17 || i==18 || i==19 || (i==15 && groupInt == 2)
                   
                   ||
                                                                                               
                    (i>19 && [upperScenes indexOfObject:[NSNumber numberWithInt:i]] != NSNotFound)
                   
                   )
                {
                    
                    NSString *customName = [MDDSHelper customSceneNameForScene:i fromJSON:customSceneNames];
                    NSString *i18nLabel = [NSString stringWithFormat:@"group%dscene%d", groupInt, i];
                    NSString *sceneTitle = NSLocalizedString(i18nLabel, @"Zone Submenu Scene X Item");
                    if(customName.length > 0)
                    {
                        DDLogVerbose(@"%@", self.zoneDict);
                        sceneTitle = [[sceneTitle stringByAppendingString:@" - "] stringByAppendingString:customName];
                    }
                    
                    
                    NSDictionary *cellDict = @{ @"title": sceneTitle, @"tag" : [NSNumber numberWithInt:i], @"group": [NSNumber numberWithInt:groupInt], @"image" : (( i == 0) ? [UIImage imageNamed:@"off_menu_icon"] : [UIImage imageNamed:[NSString stringWithFormat:@"group_%d", groupInt]])};
                    
                   
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
                            
                            
                            
                            NSDictionary *areaCellDict = @{ @"title": sceneTitle, @"tag" : [NSNumber numberWithInt:i-5], @"group": [NSNumber numberWithInt:groupInt], @"image" : (( i == 0) ? [UIImage imageNamed:@"off_menu_icon"] : [UIImage imageNamed:[NSString stringWithFormat:@"group_%d", groupInt]])};
                            
                            [areaItems addObject:areaCellDict];
                            
    //                        MDSceneMenuItem *areaSceneOff = [[MDSceneMenuItem alloc] initWithTitle:sceneTitle action:@selector(sceneMenuItemClicked:) keyEquivalent:@""];
    //                        areaSceneOff.target = item;
    //                        areaSceneOff.tag = i-5; //-5 for area off scene (check ds_basic.pdf)
    //                        areaSceneOff.group = groupInt;
    //                        areaSceneOff.image = [NSImage imageNamed:[NSString stringWithFormat:@"group_%d", groupInt]];
    //                        [areaItems addObject:areaSceneOff];
                        }
                    }
                    else
                    {
                        [(NSMutableArray *)[section objectForKey:@"cells"] addObject:cellDict];
                    }
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
    
//    // Devices Menu
//    NSArray *devices = [zoneDict objectForKey:@"devices"];
//    BOOL shouldShowDeviceMenu = NO;
//    for(NSDictionary *device in devices)
//    {
//        if([[device objectForKey:@"groups"] count] == 1 && [[device objectForKey:@"groups"] indexOfObjectIdenticalTo:[NSNumber numberWithLong:(long)8]] != NSNotFound)
//        {
//            shouldShowDeviceMenu = YES;
//        }
//    }
//    
//    if(shouldShowDeviceMenu) {
//        
//        [item.submenu addItem:[NSMenuItem separatorItem]];
//        
//        NSMenuItem *devicesItem = [[NSMenuItem alloc] init];
//        devicesItem.title = NSLocalizedString(@"menuDevices", @"Devices in Menu");
//        devicesItem.submenu = [[NSMenu alloc] init];
//        
//        // sort the devices A-Z
//        devices = [devices sortedArrayUsingComparator:^(id obj1, id obj2) {
//            return [[obj1 objectForKey:@"name"] compare:[obj2 objectForKey:@"name"]];
//        }];
//        
//        for(NSDictionary *device in devices)
//        {
//            //TODO: more flexibility with possible groups for devices
//            if(! ([[device objectForKey:@"groups"] count] == 1 && [[device objectForKey:@"groups"] indexOfObjectIdenticalTo:[NSNumber numberWithLong:(long)8]] != NSNotFound))
//            {
//                continue;
//            }
//            
//            MDDeviceMenuItem *oneDeviceItem = [[MDDeviceMenuItem alloc] init];
//            oneDeviceItem.title = [device objectForKey:@"name"];
//            oneDeviceItem.target = item;
//            oneDeviceItem.tag = 5;
//            oneDeviceItem.dsid = [device objectForKey:@"id"];
//            oneDeviceItem.action = @selector(deviceMenuItemClicked:);
//            oneDeviceItem.image = [MDDSHelper iconForDevice:device];
//            [devicesItem.submenu addItem:oneDeviceItem];
//            
//            oneDeviceItem.submenu = [[NSMenu alloc] init];
//            
//            MDDeviceMenuItem *onItem = [[MDDeviceMenuItem alloc] init];
//            onItem.title = NSLocalizedString(@"turnOn", @"Devices in Menu");
//            onItem.target = item;
//            onItem.tag = 1;
//            onItem.turnOnOffMode = YES;
//            onItem.dsid = [device objectForKey:@"id"];
//            onItem.action = @selector(deviceMenuItemClicked:);
//            [oneDeviceItem.submenu addItem:onItem];
//            
//            MDDeviceMenuItem *offItem = [[MDDeviceMenuItem alloc] init];
//            offItem.title = NSLocalizedString(@"turnOff", @"Devices in Menu");
//            offItem.target = item;
//            offItem.tag = 0;
//            offItem.turnOnOffMode = YES;
//            offItem.dsid = [device objectForKey:@"id"];
//            offItem.action = @selector(deviceMenuItemClicked:);
//            [oneDeviceItem.submenu addItem:offItem];
//        }
//        [item.submenu addItem:devicesItem];
//    }
    
    
    if([[MDIOSFavoritesManager defaultManager] favoriteForZone:[(NSNumber *)[self.zoneDict objectForKey:@"id"] stringValue] group:nil scene:nil])
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ReviewSheetStarFull.png"] style:UIBarButtonItemStylePlain target:self action:@selector(favorite)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ReviewSheetStarEmptyNew.png"] style:UIBarButtonItemStylePlain target:self action:@selector(favorite)];
    }
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
    cell.textLabel.text = [cellDict objectForKey:@"title"];
    cell.imageView.image = [cellDict objectForKey:@"image"];
    
    cell.group = [cellDict objectForKey:@"group"];
    cell.scene = [cellDict objectForKey:@"tag"];
    cell.zone = [self.zoneDict objectForKey:@"id"];
    
    [cell checkFavoriteState];
    
    return cell;
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
    
    MDIOSScenePresetTableViewCell *cell = (MDIOSScenePresetTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.isLoading = YES;
    
    [[MDDSSManager defaultManager] callScene:[cellDict objectForKey:@"tag"] zoneId:[self.zoneDict objectForKey:@"id"] groupID:[cellDict objectForKey:@"group"] callback:^(NSDictionary *json, NSError *error)
     {
         cell.isLoading = NO;
     }];
}

@end
