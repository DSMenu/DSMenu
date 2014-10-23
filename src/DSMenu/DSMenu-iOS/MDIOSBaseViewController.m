//
//  MDIOSBaseViewController.m
//  DSMenu
//
//  Created by Jonas Schnelli on 23.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSBaseViewController.h"

@interface MDIOSBaseViewController ()

@end

@implementation MDIOSBaseViewController

- (void)showNoEntriesViewWithText:(NSString *)text
{
    self.noEntriesView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.bounds.size.height)];
    self.noEntriesView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.noEntriesView];
    
    UILabel *noFavsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,10,self.view.bounds.size.width-20,self.view.bounds.size.height/2.0)];
    noFavsLabel.backgroundColor = [UIColor clearColor];
    noFavsLabel.text = text;
    noFavsLabel.font = [UIFont fontWithName:@"Helvetica Light" size:22];
    noFavsLabel.textColor = [UIColor lightGrayColor];
    noFavsLabel.numberOfLines = 10;
    noFavsLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.noEntriesView addSubview:noFavsLabel];
}

- (void)hideNoEntriesView
{
    [self.noEntriesView removeFromSuperview];
}

@end
