//
//  MDDSHelper.h
//  DSMenu
//
//  Created by Jonas Schnelli on 30.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define NSImage_OR_UIImage UIImage
#else
#define NSImage_OR_UIImage NSImage
#endif


@interface MDDSHelper : NSObject
+ (NSImage_OR_UIImage *)iconForDevice:(NSDictionary *)deviceDictonary;
+ (NSString *)customSceneNameForScene:(int)scene fromJSON:(NSArray *)json;
+ (BOOL)device:(NSDictionary *)deviceDictonary hasGroup:(NSInteger)group;
+ (BOOL)hasGroup:(int)groupNr inZone:(NSDictionary *)zoneDict;
@end
