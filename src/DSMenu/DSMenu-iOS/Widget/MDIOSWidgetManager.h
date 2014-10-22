//
//  MDIOSWidgetManager.h
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDIOSWidgetAction.h"

@interface MDIOSWidgetManager : NSObject
+ (MDIOSWidgetManager *)defaultManager;
@property NSUserDefaults *currentUserDefaults;
@property (readonly) NSArray *allFavoritesUUIDs;

- (NSDictionary *)allActions;
- (MDIOSWidgetAction *)actionForSlot:(NSInteger)slot;
- (MDIOSWidgetAction *)actionForFavoriteUUID:(NSString *)favoriteUUID;
- (void)addActionForFavoriteUUID:(NSString *)uuid;
- (void)setAction:(MDIOSWidgetAction *)action forSlot:(NSInteger)slot;
- (void)moveSlotsFromSlot:(int)fromSlot toSlot:(int)toSlot;
- (void)removeActionForFavoriteUUID:(NSString *)uuid;
@end
