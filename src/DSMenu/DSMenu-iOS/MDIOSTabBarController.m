//
//  MDIOSTabBarController.m
//  DSMenu
//
//  Created by Jonas Schnelli on 20.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSTabBarController.h"
#import "MDIOSRoomsViewController.h"
#import "MDIOSSettingsViewController.h"
#import "MDIOSConsumptionViewController.h"
#import "MDDSSManager.h"
#import "MDIOSFavoritesManager.h"

@interface MDIOSTabBarController ()

@end

@implementation MDIOSTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    for(UIViewController *viewController in self.viewControllers)
    {
        if([viewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)viewController topViewController] isKindOfClass:[MDIOSSettingsViewController class]])
        {
            viewController.tabBarItem.title = NSLocalizedString(@"settingsTitle", @"settings tabbar title");
        }
        else if([viewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)viewController topViewController] isKindOfClass:[MDIOSRoomsViewController class]])
        {
            viewController.tabBarItem.title = NSLocalizedString(@"roomsTitle", @"rooms tabbar title");
        }
        else if([viewController isKindOfClass:[MDIOSConsumptionViewController class]])
        {
            viewController.tabBarItem.title = NSLocalizedString(@"consumptionTitle", @"consumption tabbar title");
        }
    }
    
    if(![MDIOSFavoritesManager defaultManager].allFavorites || [MDIOSFavoritesManager defaultManager].allFavorites.count <= 0)
    {
        [self setSelectedIndex:1];
    }
    
    if([MDDSSManager defaultManager].host == nil || [MDDSSManager defaultManager].host.length == 0)
    {
        [self setSelectedIndex:3];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
