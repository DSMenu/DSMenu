//
//  MDDSHelper.h
//  DSMenu
//
//  Created by Jonas Schnelli on 30.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

/** 
 \defgroup core Core
 \defgroup OSX OSX
 \defgroup iOS iOS
**/

/**
 * \ingroup core
 */

#import <Foundation/Foundation.h>

// macros for iOS/OSX compatibility
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define NSImage_OR_UIImage UIImage
#else
#define NSImage_OR_UIImage NSImage
#endif

/**
 * MDDSHelper.
 *  class for doing some helping stuff
 */
@interface MDDSHelper : NSObject
+ (NSImage_OR_UIImage *)iconForDevice:(NSDictionary *)deviceDictonary;
+ (NSString *)customSceneNameForScene:(int)scene fromJSON:(NSArray *)json;
+ (BOOL)device:(NSDictionary *)deviceDictonary hasGroup:(NSInteger)group;
+ (BOOL)hasGroup:(int)groupNr inZone:(NSDictionary *)zoneDict;
@end
