//
//  MDDetailPreferencesViewController.m
//  DSMenu
//
//  Created by Jonas Schnelli on 03.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDDetailPreferencesViewController.h"
#import "MDAppDelegate.h"

@interface MDDetailPreferencesViewController ()

@end

@implementation MDDetailPreferencesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib {
    
    /* i18n */
    [self.launchAtStartupButton setTitle:NSLocalizedString(@"launchAtStartupLabel", @"Launch At Startup Label Title")];
}

- (BOOL)launchAtStartup
{
    MDAppDelegate *dele = (MDAppDelegate *)[NSApplication sharedApplication].delegate;
    return dele.launchAtStartup;
}

- (void)setLaunchAtStartup:(BOOL)aState
{
    MDAppDelegate *dele = (MDAppDelegate *)[NSApplication sharedApplication].delegate;
    dele.launchAtStartup = aState;
}

#pragma mark - RHPreferencesViewControllerProtocol

-(NSString*)identifier{
    return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage{
    return [NSImage imageNamed:@"preferences_details"];
}
-(NSString*)toolbarItemLabel{
    return NSLocalizedString(@"DetailsPreferences", @"DetailsPreferences Label");
}

-(NSView*)initialKeyView{
    return nil;
}


@end
