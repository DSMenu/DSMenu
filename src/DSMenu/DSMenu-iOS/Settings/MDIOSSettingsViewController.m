//
//  MDIOSSettingsViewController.m
//  DSMenu
//
//  Created by Jonas Schnelli on 20.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSSettingsViewController.h"

@interface MDIOSSettingsViewController ()

@end

@implementation MDIOSSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"settingsTitle", @"ios: settings root view controller");
    
    self.connectionCell.textLabel.text = NSLocalizedString(@"settingsConnection", @"ios: settings connection cell text");
    self.consumptionSettingsCell.textLabel.text = NSLocalizedString(@"settingsConsumption", @"ios: settings consumption cell text");
    self.widgetSettingsCell.textLabel.text = NSLocalizedString(@"settingsWidget", @"ios: settings Widget cell text");
    self.expertSettingsCell.textLabel.text = NSLocalizedString(@"settingsExpert", @"ios: settings experts cell text");
    
    self.connectionCell.imageView.image = [UIImage imageNamed:@"settingsTab.png"];
    self.consumptionSettingsCell.imageView.image = [UIImage imageNamed:@"chartTabbar.png"];
    self.widgetSettingsCell.imageView.image = [UIImage imageNamed:@"listTabbar.png"];
    self.expertSettingsCell.imageView.image = [UIImage imageNamed:@"settingsTab.png"];
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
