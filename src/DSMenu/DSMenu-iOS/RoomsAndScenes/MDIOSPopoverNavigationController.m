//
//  MDIOSPopoverNavigationController.m
//  DSMenu
//
//  Created by Jonas Schnelli on 31.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSPopoverNavigationController.h"

@interface MDIOSPopoverNavigationController ()

@end

@implementation MDIOSPopoverNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.preferredContentSize = CGSizeMake(250, 250);
    self.view.backgroundColor = [UIColor clearColor];
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
