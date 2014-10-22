//
//  MDDSHelper.m
//  DSMenu
//
//  Created by Jonas Schnelli on 30.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDDSHelper.h"

@interface MDDSHelper ()

@end
@implementation MDDSHelper

+ (NSImage_OR_UIImage *)iconForDevice:(NSDictionary *)deviceDictonary
{
    NSArray *groups = [(NSDictionary *)deviceDictonary objectForKey:@"groups"];
    
    NSString *iconName = @"device_unknown";
    groups = [groups sortedArrayUsingSelector:@selector(compare:)];
    if(groups.count == 2)
    {
        iconName = [NSString stringWithFormat:@"group_%@_%@", [groups objectAtIndex:0], [groups objectAtIndex:1]];
    }
    else if(groups.count == 1)
    {
        iconName = [NSString stringWithFormat:@"group_%@", [groups objectAtIndex:0]];
    }
    
    return [NSImage_OR_UIImage imageNamed:iconName];
}

+ (BOOL)device:(NSDictionary *)deviceDictonary hasGroup:(NSInteger)group
{
    NSArray *groups = [deviceDictonary objectForKey:@"groups"];
    if([groups indexOfObjectIdenticalTo:[NSNumber numberWithLong:group]] != NSNotFound)
    {
        return YES;
    }
    
    return NO;
}

+ (NSString *)customSceneNameForScene:(int)scene fromJSON:(NSArray *)json
{
    for(NSDictionary *customSceneName in json)
    {
        if([[customSceneName objectForKey:@"scene"] intValue] == scene)
        {
            return [customSceneName objectForKey:@"name"];
        }
    }
    return @"";
}

+ (BOOL)hasGroup:(int)groupNr inZone:(NSDictionary *)zoneDict
{
    for(NSDictionary *groupDict in [zoneDict objectForKey:@"groups"])
    {
        if([[groupDict objectForKey:@"color"] intValue] == groupNr)
        {
            if([[groupDict objectForKey:@"devices"] count] > 0)
            {
                return YES;
            }
        }
    }
    return NO;
}

+ (NSArray *)availableGroupsForZone:(NSDictionary *)zoneDict
{
    NSMutableArray *groups = [NSMutableArray array];
    for(int i = 1; i<9;i++)
    {
        if([self hasGroup:i inZone:zoneDict])
        {
            [groups addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    
    return groups;
}

+ (BOOL)shouldRefreshStructure:(NSDictionary *)newStructure oldStructure:(NSDictionary *)oldStructure
{
    NSMutableString *newStructureHash = [NSMutableString string];
    NSMutableString *oldStructureHash = [NSMutableString string];
    
    NSArray *newZones = [[[newStructure objectForKey:@"result"] objectForKey:@"apartment"] objectForKey:@"zones"];
    newZones = [newZones sortedArrayUsingComparator:^(id obj1, id obj2) {
        if(![obj1 objectForKey:@"name"] || [[obj1 objectForKey:@"name"] length] <= 0)
        {
            return NSOrderedDescending;
        }
        else if(![obj2 objectForKey:@"name"] || [[obj2 objectForKey:@"name"] length] <= 0)
        {
            return NSOrderedAscending;
        }
        return [[obj1 objectForKey:@"name"] compare:[obj2 objectForKey:@"name"]];
    }];
    
    // build zone menus
    for(NSDictionary *zoneDict in newZones)
    {
        if([[zoneDict objectForKey:@"id"] intValue] == 0)
        {
            // logical ID 0 room
            continue;
        }
        
        [newStructureHash appendFormat:@"%@", [zoneDict objectForKey:@"id"]];
        [newStructureHash appendFormat:@"%@", [zoneDict objectForKey:@"name"]];
    }
    
    NSArray *oldZones = [[[oldStructure objectForKey:@"result"] objectForKey:@"apartment"] objectForKey:@"zones"];
    oldZones = [oldZones sortedArrayUsingComparator:^(id obj1, id obj2) {
        if(![obj1 objectForKey:@"name"] || [[obj1 objectForKey:@"name"] length] <= 0)
        {
            return NSOrderedDescending;
        }
        else if(![obj2 objectForKey:@"name"] || [[obj2 objectForKey:@"name"] length] <= 0)
        {
            return NSOrderedAscending;
        }
        return [[obj1 objectForKey:@"name"] compare:[obj2 objectForKey:@"name"]];
    }];
    
    // build zone menus
    for(NSDictionary *zoneDict in oldZones)
    {
        if([[zoneDict objectForKey:@"id"] intValue] == 0)
        {
            // logical ID 0 room
            continue;
        }
        
        [oldStructureHash appendFormat:@"%@", [zoneDict objectForKey:@"id"]];
        [oldStructureHash appendFormat:@"%@", [zoneDict objectForKey:@"name"]];
    }
    
    
    if([newStructureHash isEqualToString:oldStructureHash])
    {
        return NO;
    }
    return YES;
}

@end
