//
//  MDZoneMenuItem.m
//  macDS
//
//  Created by Jonas Schnelli on 30.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDZoneMenuItem.h"
#import "MDDeviceMenuItem.h"
#import "MDSceneMenuItem.h"
#import "MDDSSManager.h"

@implementation MDZoneMenuItem

+ (MDZoneMenuItem *)menuItemWithZoneDictionary:(NSDictionary *)zoneDict
{
    DDLogDebug(@"%@", zoneDict);
    
    MDZoneMenuItem *item = [[MDZoneMenuItem alloc] init];
    item.title = [zoneDict objectForKey:@"name"];
    item.zoneId = [zoneDict objectForKey:@"id"];
    
    if(item.title.length <= 0)
    {
        item.title = [NSLocalizedString(@"unnamedRoom", @"Menu String for unnamed room") stringByAppendingFormat:@" %@", item.zoneId];
    }
    
    item.submenu = [[NSMenu alloc] init];

    // TODO: for the moment, only scene 0, 5, 17, 18, 19 are available
    if([MDDSHelper hasGroup:1 inZone:zoneDict])
    {
        NSArray *customSceneNames = [[MDDSSManager defaultManager] customSceneNamesForGroup:1 inZone:[[zoneDict objectForKey:@"id"] intValue]];
        if(customSceneNames)
        {
            NSLog(@"%@", customSceneNames);
        }
        ///// light (group 1)
        for(int i=0;i<=19;i++)
        {
            if((i > 0 && i < 5) || (i > 5 && i < 17))
            {
                continue;
            }

            NSString *customName = [MDDSHelper customSceneNameForScene:i fromJSON:customSceneNames];
            NSString *sceneTitle = NSLocalizedString(([@"lightSceneItem" stringByAppendingFormat:@"%d", i]), @"Zone Submenu Scene X Item");
            if(customName.length > 0)
            {
                NSLog(@"%@", zoneDict);
                sceneTitle = [[sceneTitle stringByAppendingString:@" - "] stringByAppendingString:customName];
            }
            MDSceneMenuItem *lightScene = [[MDSceneMenuItem alloc] initWithTitle:sceneTitle action:@selector(sceneMenuItemClicked:) keyEquivalent:@""];
            lightScene.target = item;
            lightScene.tag = i;
            lightScene.group = 1;
            lightScene.image = ( i == 0) ? [NSImage imageNamed:@"off_menu_icon"] : [NSImage imageNamed:@"group_1"];
            [item.submenu addItem:lightScene];
        }
        
        [item.submenu addItem:[NSMenuItem separatorItem]];
        ////////////////////////
    }
    
    
    if([MDDSHelper hasGroup:2 inZone:zoneDict])
    {
        for(int i=0;i<=19;i++)
        {
            if((i > 0 && i < 5) || (i > 5 && i < 17))
            {
                continue;
            }
            MDSceneMenuItem *shadowScene = [[MDSceneMenuItem alloc] initWithTitle:NSLocalizedString(([@"shadowSceneItem" stringByAppendingFormat:@"%d", i]), @"Zone Submenu Scene X Item") action:@selector(sceneMenuItemClicked:) keyEquivalent:@""];
            shadowScene.target = item;
            shadowScene.tag = i;
            shadowScene.group = 2;
            shadowScene.image = ( i == 0) ? [NSImage imageNamed:@"off_menu_icon"] : [NSImage imageNamed:@"group_2"];
            [item.submenu addItem:shadowScene];
        }
        
        [item.submenu addItem:[NSMenuItem separatorItem]];
        ////////////////////////
    }
    
    
    // Deep Off

    MDSceneMenuItem *deepOffScene = [[MDSceneMenuItem alloc] initWithTitle:NSLocalizedString(@"deeopOffSceneItem", @"Zone Submenu Scene X Item") action:@selector(sceneMenuItemClicked:) keyEquivalent:@""];
    deepOffScene.target = item;
    deepOffScene.tag = 68;
    deepOffScene.group = 1;
    deepOffScene.image = [NSImage imageNamed:@"group_2"];
    [item.submenu addItem:deepOffScene];
    
    [item.submenu addItem:[NSMenuItem separatorItem]];
    
    
    // Devices Menu
    NSMenuItem *devicesItem = [[NSMenuItem alloc] init];
    devicesItem.title = NSLocalizedString(@"menuDevices", @"Devices in Menu");
    devicesItem.submenu = [[NSMenu alloc] init];
    
    // sort the devices A-Z
    NSArray *devices = [zoneDict objectForKey:@"devices"];
    devices = [devices sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj1 objectForKey:@"name"] compare:[obj2 objectForKey:@"name"]];
    }];
    
    for(NSDictionary *device in devices)
    {
        MDDeviceMenuItem *oneDeviceItem = [[MDDeviceMenuItem alloc] init];
        oneDeviceItem.title = [device objectForKey:@"name"];
        oneDeviceItem.target = item;
        oneDeviceItem.tag = 5;
        oneDeviceItem.dsid = [device objectForKey:@"id"];
        oneDeviceItem.action = @selector(deviceMenuItemClicked:);
        oneDeviceItem.image = [MDDSHelper iconForDevice:device];
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
        [oneDeviceItem.submenu addItem:[NSMenuItem separatorItem]];
        
        if([MDDSHelper deviceHasLight:device])
        {
            ///// DEVICE light (group 1)
            for(int i=0;i<=19;i++)
            {
                if((i > 0 && i < 5) || (i > 5 && i < 17))
                {
                    continue;
                }
                MDDeviceMenuItem *lightScene = [[MDDeviceMenuItem alloc] initWithTitle:NSLocalizedString(([@"lightSceneItem" stringByAppendingFormat:@"%d", i]), @"Zone Submenu Scene X Item") action:@selector(deviceMenuItemClicked:) keyEquivalent:@""];
                lightScene.target = item;
                lightScene.tag = i;
                lightScene.dsid = [device objectForKey:@"id"];
                lightScene.group = 1;
                lightScene.image = ( i == 0) ? [NSImage imageNamed:@"off_menu_icon"] : [NSImage imageNamed:@"group_1"];
                [oneDeviceItem.submenu addItem:lightScene];
            }
            
            [oneDeviceItem.submenu addItem:[NSMenuItem separatorItem]];
            ////////////////////////
        }
        
        
        if([MDDSHelper deviceHasShadow:device])
        {
            ///// DEVICE shadow (group 2)
            for(int i=0;i<=19;i++)
            {
                if((i > 0 && i < 5) || (i > 5 && i < 17))
                {
                    continue;
                }
                MDDeviceMenuItem *shadowScene = [[MDDeviceMenuItem alloc] initWithTitle:NSLocalizedString(([@"shadowSceneItem" stringByAppendingFormat:@"%d", i]), @"Zone Submenu Scene X Item") action:@selector(deviceMenuItemClicked:) keyEquivalent:@""];
                shadowScene.target = item;
                shadowScene.tag = i;
                shadowScene.dsid = [device objectForKey:@"id"];
                shadowScene.group = 2;
                shadowScene.image = ( i == 0) ? [NSImage imageNamed:@"off_menu_icon"] : [NSImage imageNamed:@"group_2"];
                [oneDeviceItem.submenu addItem:shadowScene];
            }
            
            [oneDeviceItem.submenu addItem:[NSMenuItem separatorItem]];
            ////////////////////////
        }
        
    }
    [item.submenu addItem:devicesItem];
    
    
    return item;
}

- (void)sceneMenuItemClicked:(id)sender
{
    self.clickedSubmenu = (MDSceneMenuItem *)sender;
    self.clickType = MDZoneMenuItemClickTypeScene;
    [self.target performSelector:self.action withObject:self]; //<TODO: refactor
}

- (void)deviceMenuItemClicked:(id)sender
{
    self.clickedSubmenu = (MDSceneMenuItem *)sender;
    self.clickType = MDZoneMenuItemClickTypeDevice;
    [self.target performSelector:self.action withObject:self]; //<TODO: refactor
}



@end
