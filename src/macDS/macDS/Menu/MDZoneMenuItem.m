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
    MDZoneMenuItem *item = [[MDZoneMenuItem alloc] init];
    item.title = [zoneDict objectForKey:@"name"];
    item.zoneId = [zoneDict objectForKey:@"id"];
    
    if(item.title.length <= 0)
    {
        // define unnamed room
        item.title = [NSLocalizedString(@"unnamedRoom", @"Menu String for unnamed room") stringByAppendingFormat:@" %@", item.zoneId];
    }
    
    item.submenu = [[NSMenu alloc] init];

    
    NSArray *buildGroups = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:2], nil];
    for(NSNumber *group in buildGroups)
    {
        int groupInt = [group intValue];
        
        if([MDDSHelper hasGroup:groupInt inZone:zoneDict])
        {
            // check is there are possible areas
            NSMutableArray *areas       = [[NSMutableArray alloc] init];
            NSMutableArray *areaItems   = [[NSMutableArray alloc] init];
            for(NSDictionary *device in [zoneDict objectForKey:@"devices"])
            {
                if([[device objectForKey:@"buttonActiveGroup"] intValue] == groupInt && [[device objectForKey:@"buttonID"] intValue] > 0 && [[device objectForKey:@"buttonID"] intValue] < 4)
                {
                    [areas addObject:[device objectForKey:@"buttonID"]];
                }
            }
            
            // load custom scene names
            NSArray *customSceneNames = [[MDDSSManager defaultManager] customSceneNamesForGroup:groupInt inZone:[[zoneDict objectForKey:@"id"] intValue]];
            if(customSceneNames)
            {
                DDLogVerbose(@"found custom scene name: %@ for %d", customSceneNames, groupInt);
            }
            for(int i=0;i<=19;i++)
            {
                if(!(i==0 || i==5 || i==6 || i==7 || i==8 || i==9 || i==17 || i==18 || i==19 || (i==15 && groupInt == 2)))
                {
                    continue;
                }
                
                NSString *customName = [MDDSHelper customSceneNameForScene:i fromJSON:customSceneNames];
                NSString *i18nLabel = [NSString stringWithFormat:@"group%dscene%d", groupInt, i];
                NSString *sceneTitle = NSLocalizedString(i18nLabel, @"Zone Submenu Scene X Item");
                if(customName.length > 0)
                {
                    DDLogVerbose(@"%@", zoneDict);
                    sceneTitle = [[sceneTitle stringByAppendingString:@" - "] stringByAppendingString:customName];
                }
                MDSceneMenuItem *lightScene = [[MDSceneMenuItem alloc] initWithTitle:sceneTitle action:@selector(sceneMenuItemClicked:) keyEquivalent:@""];
                lightScene.target = item;
                lightScene.tag = i;
                lightScene.group = groupInt;
                lightScene.image = ( i == 0) ? [NSImage imageNamed:@"off_menu_icon"] : [NSImage imageNamed:[NSString stringWithFormat:@"group_%d", groupInt]];
                
                // Area Scenes
                if( (i==6 || i==7 || i==8 || i==9 ) )
                {
                    // only add if the area is present
                    if(([areas indexOfObjectIdenticalTo:[NSNumber numberWithLong:(long)(i-5)]] != NSNotFound))
                    {
                        [areaItems addObject:lightScene];
                        
                        NSString *customName = [MDDSHelper customSceneNameForScene:i-5 fromJSON:customSceneNames]; //-5 for area off scene (check ds_basic.pdf)
                        NSString *i18nLabel = [NSString stringWithFormat:@"group%dscene%d", groupInt, i-5];
                        NSString *sceneTitle = NSLocalizedString(i18nLabel, @"Zone Submenu Scene X Item");
                        if(customName.length > 0)
                        {
                            DDLogVerbose(@"%@", zoneDict);
                            sceneTitle = [[sceneTitle stringByAppendingString:@" - "] stringByAppendingString:customName];
                        }
                        
                        MDSceneMenuItem *areaSceneOff = [[MDSceneMenuItem alloc] initWithTitle:sceneTitle action:@selector(sceneMenuItemClicked:) keyEquivalent:@""];
                        areaSceneOff.target = item;
                        areaSceneOff.tag = i-5; //-5 for area off scene (check ds_basic.pdf)
                        areaSceneOff.group = groupInt;
                        areaSceneOff.image = [NSImage imageNamed:[NSString stringWithFormat:@"group_%d", groupInt]];
                        [areaItems addObject:areaSceneOff];
                    }
                }
                else
                {
                    [item.submenu addItem:lightScene];
                }
            }
            
            // add area items at bottom
            for(NSMenuItem *areaItem in areaItems)
            {
                [item.submenu addItem:areaItem];
            }
            
            [item.submenu addItem:[NSMenuItem separatorItem]];
            ////////////////////////
        }
    }
    
    // Deep Off
    MDSceneMenuItem *deepOffScene = [[MDSceneMenuItem alloc] initWithTitle:NSLocalizedString(@"deeopOffSceneItem", @"Zone Submenu Scene X Item") action:@selector(sceneMenuItemClicked:) keyEquivalent:@""];
    deepOffScene.target = item;
    deepOffScene.tag = 68;
    deepOffScene.group = 1;
    deepOffScene.image = [NSImage imageNamed:@"group_2"];
    [item.submenu addItem:deepOffScene];
    
    // Devices Menu
    NSArray *devices = [zoneDict objectForKey:@"devices"];
    BOOL shouldShowDeviceMenu = NO;
    for(NSDictionary *device in devices)
    {
        if([[device objectForKey:@"groups"] count] == 1 && [[device objectForKey:@"groups"] indexOfObjectIdenticalTo:[NSNumber numberWithLong:(long)8]] != NSNotFound)
        {
            shouldShowDeviceMenu = YES;
        }
    }
    
    if(shouldShowDeviceMenu) {
        
        [item.submenu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *devicesItem = [[NSMenuItem alloc] init];
        devicesItem.title = NSLocalizedString(@"menuDevices", @"Devices in Menu");
        devicesItem.submenu = [[NSMenu alloc] init];
        
        // sort the devices A-Z
        devices = [devices sortedArrayUsingComparator:^(id obj1, id obj2) {
            return [[obj1 objectForKey:@"name"] compare:[obj2 objectForKey:@"name"]];
        }];
        
        for(NSDictionary *device in devices)
        {
            //TODO: more flexibility with possible groups for devices
            if(! ([[device objectForKey:@"groups"] count] == 1 && [[device objectForKey:@"groups"] indexOfObjectIdenticalTo:[NSNumber numberWithLong:(long)8]] != NSNotFound))
            {
                continue;
            }
            
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
            onItem.tag = 1;
            onItem.turnOnOffMode = YES;
            onItem.dsid = [device objectForKey:@"id"];
            onItem.action = @selector(deviceMenuItemClicked:);
            [oneDeviceItem.submenu addItem:onItem];

            MDDeviceMenuItem *offItem = [[MDDeviceMenuItem alloc] init];
            offItem.title = NSLocalizedString(@"turnOff", @"Devices in Menu");
            offItem.target = item;
            offItem.tag = 0;
            offItem.turnOnOffMode = YES;
            offItem.dsid = [device objectForKey:@"id"];
            offItem.action = @selector(deviceMenuItemClicked:);
            [oneDeviceItem.submenu addItem:offItem];
        }
        [item.submenu addItem:devicesItem];
    }
    
    
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
