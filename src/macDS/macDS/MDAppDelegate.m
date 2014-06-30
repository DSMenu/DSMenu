//
//  MDAppDelegate.m
//  macDS
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDAppDelegate.h"
#import "MDDSSManager.h"
#import "MDZoneMenuItem.h"
#import "MDDeviceMenuItem.h"

@interface MDAppDelegate ()
@property (strong) NSStatusItem * statusItem;
@property (assign) IBOutlet NSMenu *statusMenu;
@end

@implementation MDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    // make a global menu (extra menu) item
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    self.statusMenu.delegate = self;
    [self.statusItem setTitle:@""];
    [self.statusItem setHighlightMode:YES];
    
    [self.statusItem setImage:[NSImage imageNamed:@"status_bar_icon"]];
    
    [self refreshMenu];
}

- (void)refreshMenu
{
    [MDDSSManager defaultManager].appName = @"macDS";
    [MDDSSManager defaultManager].host = @"10.0.1.21";
    
    if(![MDDSSManager defaultManager].hasApplicationToken)
    {
        [[MDDSSManager defaultManager] requestApplicationToken:^(NSDictionary *json, NSError *error){
             [self refreshStructure];
        }];
    }
    else
    {
        [self refreshStructure];
    }
    
}

- (void)refreshStructure
{
    [[MDDSSManager defaultManager] getStructure:^(NSDictionary *json, NSError *error){
        
        [self.statusMenu removeAllItems];
        for(NSDictionary *zoneDict in [[[json objectForKey:@"result"] objectForKey:@"apartment"] objectForKey:@"zones"])
        {
            MDZoneMenuItem *menuItem = [MDZoneMenuItem menuItemWithZoneDictionary:zoneDict];
            menuItem.target = self;
            menuItem.action = @selector(zoneMenuItemClicked:);
            [self.statusMenu addItem:menuItem];
        }
    }];
}

- (void)zoneMenuItemClicked:(id)sender
{
    MDZoneMenuItem *zoneMenuItem = (MDZoneMenuItem *)sender;
    
    NSString *scene = @"0";
    if(zoneMenuItem.clickedSubmenu) {
        scene = [NSString stringWithFormat:@"%d", zoneMenuItem.clickedSubmenu.tag];
    }
    
    if(zoneMenuItem.clickType == MDZoneMenuItemClickTypeScene)
    {
        [[MDDSSManager defaultManager] callScene:scene zoneId:zoneMenuItem.zoneId groupID:@"1" callback:^(NSDictionary *json, NSError *error){
            
        }];
    }
    else if(zoneMenuItem.clickType == MDZoneMenuItemClickTypeDevice)
    {
        MDDeviceMenuItem *deviceMenuItem = (MDDeviceMenuItem *)zoneMenuItem.clickedSubmenu;
        [[MDDSSManager defaultManager] callScene:scene deviceId:deviceMenuItem.dsid callback:^(NSDictionary *json, NSError *error){
           
        }];
    }
    
}

@end
