//
//  MDIOSPopoverViewController.m
//  DSMenu
//
//  Created by Jonas Schnelli on 30.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSPopoverViewController.h"
#import "MDDSSManager.h"

@interface MDIOSPopoverViewController ()
@property (strong) NSMutableArray *actions;
@property UIActivityIndicatorView *activityIndicator;
@end

@implementation MDIOSPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator stopAnimating];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
    
    if(!self.userDefinedActions)
    {
        self.actions = (NSMutableArray *)@[
                          @{@"scene": @"uda", @"title": NSLocalizedString(@"userDefinedActionsTitle", @"")},
                          @{@"scene": @"72", @"title": NSLocalizedString(@"Absent", @"")},
                          @{@"scene": @"73", @"title": NSLocalizedString(@"DoorBell", @"")},
                          @{@"scene": @"71", @"title": NSLocalizedString(@"Present", @"")},
                          @{@"scene": @"69", @"title": NSLocalizedString(@"Sleeping", @"")},
                          @{@"scene": @"70", @"title": NSLocalizedString(@"Wakeup", @"")},
                          @{@"scene": @"65", @"title": NSLocalizedString(@"Panic", @"")},
                          ];
        
        self.title = NSLocalizedString(@"globalActionsTitle", @"");
    }
    else
    {
        self.title = NSLocalizedString(@"userDefinedActionsTitle", @"");
        [self showLoading:YES];
        [[MDDSSManager defaultManager] allUserdefinedActions:^(NSDictionary *json, NSError *error) {
            if(json && [json objectForKey:@"result"] && [[json objectForKey:@"result"] objectForKey:@"events"])
            {
                self.actions = [NSMutableArray array];
                
                for(NSDictionary *dict in [[json objectForKey:@"result"] objectForKey:@"events"])
                {
                    [self.actions addObject:@{@"scene": @"event", @"title": [dict objectForKey:@"name"], @"id": [dict objectForKey:@"id"]}];
                }
                
                [self showLoading:NO];
                [self.tableView reloadData];
            }
        }];
    }
    
    self.preferredContentSize = CGSizeMake(250, 180);
    //self.view.backgroundColor = [UIColor clearColor];
    //self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)showLoading:(BOOL)state
{
    state ? [self.activityIndicator startAnimating] : [self.activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.actions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GlobalActionCell"];
    UILabel *mainLabel          = (UILabel *)[cell viewWithTag:1];
    UIButton *favoriteButton    = (UIButton *)[cell viewWithTag:2];
    favoriteButton.hidden = YES;

    
    NSDictionary *data = [self.actions objectAtIndex:indexPath.row];
    mainLabel.text = [data objectForKey:@"title"];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if([[data objectForKey:@"scene"] isEqualToString:@"uda"])
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *data = [self.actions objectAtIndex:indexPath.row];
    if([[data objectForKey:@"scene"] isEqualToString:@"uda"])
    {
        MDIOSPopoverViewController *nextController = [self.storyboard instantiateViewControllerWithIdentifier:@"Popover"];
        nextController.userDefinedActions = YES;
        [self.navigationController pushViewController:nextController animated:YES];
        return;
    }
    else if([[data objectForKey:@"scene"] isEqualToString:@"event"])
    {
        [[MDDSSManager defaultManager] raiseEvent:[data objectForKey:@"id"] callback:^(NSDictionary *json, NSError *error) {
   
        }];
    }
    else
    {
        [[MDDSSManager defaultManager] callScene:[data objectForKey:@"scene"] callback:^(NSDictionary *json, NSError *error) {
            
        }];
    }
}

@end
