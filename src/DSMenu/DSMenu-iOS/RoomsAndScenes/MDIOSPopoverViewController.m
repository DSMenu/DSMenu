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
@property (strong) NSArray *actions;
@end

@implementation MDIOSPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.actions = @[ @{@"scene": @"72", @"title": NSLocalizedString(@"Absent", @"")},
                      @{@"scene": @"73", @"title": NSLocalizedString(@"DoorBell", @"")},
                      @{@"scene": @"71", @"title": NSLocalizedString(@"Present", @"")},
                      @{@"scene": @"69", @"title": NSLocalizedString(@"Sleeping", @"")},
                      @{@"scene": @"70", @"title": NSLocalizedString(@"Wakeup", @"")},
                      @{@"scene": @"65", @"title": NSLocalizedString(@"Panic", @"")},
                      ];
    
    self.preferredContentSize = CGSizeMake(250, 180);
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
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *data = [self.actions objectAtIndex:indexPath.row];
    [[MDDSSManager defaultManager] callScene:[data objectForKey:@"scene"] callback:^(NSDictionary *json, NSError *error) {
        
    }];
}

@end
