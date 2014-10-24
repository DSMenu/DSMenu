//
//  MDIOSFavoritesViewController.m
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSFavoritesViewController.h"
#import "MDIOSFavoritesManager.h"
#import "MDDSSManager.h"
#import "MDIOSFavoriteTableViewCell.h"
#import "MDIOSScenesTableViewController.h"
#import "MDIOSWidgetManager.h"

@interface MDIOSFavoritesViewController ()

@end

@implementation MDIOSFavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTable:) name:kDS_STRUCTURE_DID_CHANGE object:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"favEdit", @"") style:UIBarButtonItemStylePlain target:self action:@selector(switchEdit)];
    
    self.title = NSLocalizedString(@"favorites", @"favorites navbar title");
}

- (void)checkIfThereAreEntries
{
    if(![MDIOSFavoritesManager defaultManager].allFavorites || [MDIOSFavoritesManager defaultManager].allFavorites.count <=0)
    {
        [self showNoEntriesViewWithText:NSLocalizedString(@"noFavoritesAvailable", @"")];
    }
    else
    {
        [self hideNoEntriesView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkIfThereAreEntries];
    [self.tableView reloadData];
    
    if(self.widgetMode)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)switchEdit
{
    self.tableView.editing = !self.tableView.editing;
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString( (self.tableView.editing ? @"favEditEnd" : @"favEdit"), @"");
}

- (void)updateTable:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    [[MDIOSFavoritesManager defaultManager] exchangeFavoriteFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    
    [self.tableView reloadData];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[MDIOSFavoritesManager defaultManager] removeFavoriteAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [MDIOSFavoritesManager defaultManager].allFavorites.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MDIOSFavoriteTableViewCell *cell = (MDIOSFavoriteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FavoriteCell"];
    if (cell == nil)
    {
        cell = [[MDIOSFavoriteTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FavoriteCell"];
    }
    

    MDIOSFavorite *fav = [[MDIOSFavoritesManager defaultManager].allFavorites objectAtIndex:indexPath.row];

    NSDictionary *json = [MDDSSManager defaultManager].lastLoadesStructure;
    NSDictionary *zoneDict = nil;
    if(json && [json objectForKey:@"result"] && [[json objectForKey:@"result"] objectForKey:@"apartment"])
    {
        NSArray *zones = [[[json objectForKey:@"result"] objectForKey:@"apartment"] objectForKey:@"zones"];
        NSString *zoneName = @"";
        for(NSDictionary *aZoneDict in zones)
        {
            if([[(NSNumber *) [aZoneDict objectForKey:@"id"] stringValue] isEqualToString:fav.zone])
            {
                zoneName = [aZoneDict objectForKey:@"name"];
                zoneDict = aZoneDict;
                break;
            }
        }
        cell.textLabel.text = zoneName;
    }
    else
    {
        cell.textLabel.text = fav.zone;
    }
    
    cell.zoneId = fav.zone;
    
    if(fav.favoriteType == MDIOSFavoriteTypeZone || (fav.group == nil && fav.scene == nil))
    {
        cell.subtitle.text = nil;
        cell.mainLabel.text = cell.textLabel.text;
        cell.textLabel.text = @"";
        
        if(zoneDict)
        {
            [cell buildLabels:[MDDSHelper availableGroupsForZone:zoneDict]];
        }
    }
    else
    {
        UITableViewCell *cell2 = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FavoriteSceneCell"];
        if (cell2 == nil)
        {
            cell2 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FavoriteSceneCell"];
        }
        
        NSArray *customSceneNames = [[MDDSSManager defaultManager] customSceneNamesForGroup:fav.group.intValue inZone:fav.zone.intValue];
        if(customSceneNames)
        {
            cell2.detailTextLabel.text = [MDDSHelper customSceneNameForScene:fav.scene.intValue fromJSON:customSceneNames];
        }
        else
        {
            cell2.detailTextLabel.text = NSLocalizedString(([NSString stringWithFormat:@"group%@scene%@", fav.group, fav.scene]), @"");
        }
        
        cell2.textLabel.text = cell.textLabel.text;
        
        cell2.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:(NSLocalizedString(@"group_%d.png", @"")), fav.group.intValue]];
        
        if(fav.scene.intValue == 0)
        {
            cell2.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:(NSLocalizedString(@"off_menu_icon.png", @"")), fav.group.intValue]];
        }
        
        cell = (MDIOSFavoriteTableViewCell *)cell2;
    }
    
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ReviewSheetStarFull.png"]];
    
    if(self.widgetMode)
    {
        UISwitch *aSwitch = [[UISwitch alloc] init];
        MDIOSWidgetAction *action = [[MDIOSWidgetManager defaultManager] actionForFavoriteUUID:fav.UUID];
        if(action)
        {
            aSwitch.on = YES;
            
        }
        aSwitch.tag = indexPath.row;
        [aSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = aSwitch;
    }
    
    return cell;
}

- (void)switchChanged:(id)sender
{
    UISwitch *aSwitch = (UISwitch *)sender;
    
    MDIOSFavorite *fav = [[MDIOSFavoritesManager defaultManager].allFavorites objectAtIndex:aSwitch.tag];
    if(aSwitch.on)
    {
        [[MDIOSWidgetManager defaultManager] addActionForFavoriteUUID:fav.UUID];
    }
    else
    {
        [[MDIOSWidgetManager defaultManager] removeActionForFavoriteUUID:fav.UUID];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.widgetMode)
    {
        return;
    }
    MDIOSFavorite *fav = [[MDIOSFavoritesManager defaultManager].allFavorites objectAtIndex:indexPath.row];
    
    if(fav.favoriteType == MDIOSFavoriteTypeZone || (fav.group == nil && fav.scene == nil))
    {
        NSDictionary *json = [MDDSSManager defaultManager].lastLoadesStructure;
        if(json && [json objectForKey:@"result"] && [[json objectForKey:@"result"] objectForKey:@"apartment"])
        {
            NSArray *zones = [[[json objectForKey:@"result"] objectForKey:@"apartment"] objectForKey:@"zones"];
            for(NSDictionary *aZoneDict in zones)
            {
                if([[(NSNumber *) [aZoneDict objectForKey:@"id"] stringValue] isEqualToString:fav.zone])
                {
                    MDIOSScenesTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Scenes"];
                    controller.zoneDict = aZoneDict;
                    [self.navigationController pushViewController:controller animated:YES];
                    
                    break;
                }
            }
        }
    }
    else
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator startAnimating];
        cell.accessoryView = activityIndicator;
        
        [[MDDSSManager defaultManager] callScene:fav.scene zoneId:fav.zone groupID:fav.group callback:^(NSDictionary *json, NSError *error)
         {
             cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ReviewSheetStarFull.png"]];
         }];
    }
    
    
}

@end
