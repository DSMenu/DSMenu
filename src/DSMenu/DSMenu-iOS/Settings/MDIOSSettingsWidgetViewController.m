//
//  MDIOSSettingsWidgetViewController.m
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSSettingsWidgetViewController.h"
#import "MDIOSRoomsViewController.h"
#import "MDIOSWidgetManager.h"
#import "MDIOSFavoritesViewController.h"

@interface MDIOSSettingsWidgetViewController ()
@property (strong) NSIndexPath *lastSelectedIndexPath;
@end

@implementation MDIOSSettingsWidgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectFavoritesCell.textLabel.text = NSLocalizedString(@"selectFavoritesForWidgetCell", @"");
}

- (void)delayedPromptRemove
{
    self.navigationItem.prompt = @"";
    self.navigationItem.prompt = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MDIOSFavoritesViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Favorites"];
    controller.widgetMode = YES;
    controller.navigationItem.prompt = [NSString stringWithFormat:(NSLocalizedString(@"selectActionPrompt", @"")), indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Rooms View Controller Delegate Stack

- (void)roomsOrScenesViewController:(MDIOSRoomsViewController *)controller didSelectAction:(MDIOSWidgetAction *)action
{
    [[MDIOSWidgetManager defaultManager] setAction:action forSlot:self.lastSelectedIndexPath.row];
    
    self.navigationItem.prompt = nil;
    [self.navigationController popToViewController:self animated:YES];
    
    [self.tableView reloadData];
    
    [self performSelector:@selector(delayedPromptRemove) withObject:nil afterDelay:0.5];
}

@end
