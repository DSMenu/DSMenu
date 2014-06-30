//
//  MDZoneMenuItem.m
//  macDS
//
//  Created by Jonas Schnelli on 30.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDZoneMenuItem.h"
#import "MDDeviceMenuItem.h"

@implementation MDZoneMenuItem

+ (MDZoneMenuItem *)menuItemWithZoneDictionary:(NSDictionary *)zoneDict
{
    NSLog(@"%@", zoneDict);
    
    MDZoneMenuItem *item = [[MDZoneMenuItem alloc] init];
    item.title = [zoneDict objectForKey:@"name"];
    item.zoneId = [zoneDict objectForKey:@"id"];
    
    item.submenu = [[NSMenu alloc] init];
    [item.submenu setAutoenablesItems:YES];
    
    NSMenuItem *scene4 = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"sceneItem0", @"Zone Submenu Scene 0 Item") action:@selector(sceneMenuItemClicked:) keyEquivalent:@""];
    scene4.target = item;
    scene4.tag = 0;
    [item.submenu addItem:scene4];
    
    NSMenuItem *scene5 = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"sceneItem5", @"Zone Submenu Scene 5 Item") action:@selector(sceneMenuItemClicked:) keyEquivalent:@""];
    scene5.target = item;
    scene5.tag = 5;
    [item.submenu addItem:scene5];
    
    [item.submenu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *devicesItem = [[NSMenuItem alloc] init];
    devicesItem.title = NSLocalizedString(@"menuDevices", @"Devices in Menu");
    devicesItem.submenu = [[NSMenu alloc] init];
    
    for(NSDictionary *device in [zoneDict objectForKey:@"devices"])
    {
        MDDeviceMenuItem *oneDeviceItem = [[MDDeviceMenuItem alloc] init];
        oneDeviceItem.title = [device objectForKey:@"name"];
        oneDeviceItem.target = item;
        oneDeviceItem.tag = 5;
        oneDeviceItem.dsid = [device objectForKey:@"id"];
        oneDeviceItem.action = @selector(deviceMenuItemClicked:);
        [devicesItem.submenu addItem:oneDeviceItem];
        
        oneDeviceItem.submenu = [[NSMenu alloc] init];

        MDDeviceMenuItem *onItem = [[MDDeviceMenuItem alloc] init];
        onItem.title = NSLocalizedString(@"turnOn", @"Devices in Menu");
        onItem.target = item;
        onItem.tag = 5;
        onItem.dsid = [device objectForKey:@"id"];
        onItem.action = @selector(deviceMenuItemClicked:);
        [oneDeviceItem.submenu addItem:onItem];

        MDDeviceMenuItem *offItem = [[MDDeviceMenuItem alloc] init];
        offItem.title = NSLocalizedString(@"turnOff", @"Devices in Menu");
        offItem.target = item;
        offItem.tag = 0;
        offItem.dsid = [device objectForKey:@"id"];
        offItem.action = @selector(deviceMenuItemClicked:);
        [oneDeviceItem.submenu addItem:offItem];
        
    }
    [item.submenu addItem:devicesItem];
    
    
    return item;
}

- (void)sceneMenuItemClicked:(id)sender
{
    self.clickedSubmenu = (NSMenuItem *)sender;
    self.clickType = MDZoneMenuItemClickTypeScene;
    [self.target performSelector:self.action withObject:self]; //<TODO: refactor
}

- (void)deviceMenuItemClicked:(id)sender
{
    self.clickedSubmenu = (NSMenuItem *)sender;
    self.clickType = MDZoneMenuItemClickTypeDevice;
    [self.target performSelector:self.action withObject:self]; //<TODO: refactor
}




@end
