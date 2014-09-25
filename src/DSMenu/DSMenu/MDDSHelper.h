//
//  MDDSHelper.h
//  DSMenu
//
//  Created by Jonas Schnelli on 30.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDDSHelper : NSObject
+ (NSImage *)iconForDevice:(NSDictionary *)deviceDictonary;
+ (NSString *)customSceneNameForScene:(int)scene fromJSON:(NSArray *)json;
+ (BOOL)device:(NSDictionary *)deviceDictonary hasGroup:(NSInteger)group;
+ (BOOL)hasGroup:(int)groupNr inZone:(NSDictionary *)zoneDict;
@end
