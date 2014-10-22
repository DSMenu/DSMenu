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

@interface MDIOSSettingsWidgetViewController ()
@property (strong) NSIndexPath *lastSelectedIndexPath;
@end

@implementation MDIOSSettingsWidgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.editItem.title = NSLocalizedString(@"reorderTable", @"reorder widgets");
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 1)
    {
        return 6;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    cell.textLabel.text = [NSString stringWithFormat:(NSLocalizedString(@"widgetCellText", @"")), indexPath.row];
    
    MDIOSWidgetAction *action = [[MDIOSWidgetManager defaultManager] actionForSlot:indexPath.row];
    if(action)
    {
        cell.detailTextLabel.text = cell.textLabel.text;
        cell.textLabel.text = action.title;
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"group_%@.png", action.group]];
    }
    else
    {
        cell.detailTextLabel.text = @"<empty>";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.lastSelectedIndexPath = indexPath;
    
    MDIOSRoomsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Rooms"];
    controller.selectWidgetMode = YES;
    controller.delegate = self;
    controller.navigationItem.prompt = [NSString stringWithFormat:(NSLocalizedString(@"selectActionPrompt", @"")), indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    int fromRow = sourceIndexPath.row;
    int toRow = destinationIndexPath.row;
    
    [[MDIOSWidgetManager defaultManager] moveSlotsFromSlot:fromRow toSlot:toRow];
    [self.tableView reloadData];
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

#pragma mark - IBActions

- (IBAction)editAction:(id)sender
{
    self.tableView.editing = !self.tableView.editing;
    self.editItem.title = self.tableView.editing ? NSLocalizedString(@"reorderTableEnd", @"reorder widgets") : NSLocalizedString(@"reorderTable", @"reorder widgets");
}

@end
