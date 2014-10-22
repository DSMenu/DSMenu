//
//  MDIOSFavoritesManager.h
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDIOSFavorite.h"

@interface MDIOSFavoritesManager : NSObject
+ (MDIOSFavoritesManager *)defaultManager;
@property NSUserDefaults *currentUserDefaults;
@property (readonly) NSArray *allFavorites;
- (MDIOSFavorite *)favoriteForZone:(NSString *)zone group:(NSString *)group scene:(NSString *)scene;
- (MDIOSFavorite *)favoriteForUUID:(NSString *)uuid;
- (void)addFavorit:(MDIOSFavorite *)favorite;
- (void)removeFavorite:(MDIOSFavorite *)favorite;
- (void)removeFavoriteAtIndex:(NSInteger)index;
- (void)exchangeFavoriteFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end
