//
//  MDIOSFavorite.h
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum MDIOSFavoriteType
{
    MDIOSFavoriteTypeZone = 1,
    MDIOSFavoriteTypeZonePreset = 2
} MDIOSFavoriteType;


@interface MDIOSFavorite : NSObject

@property (strong) NSString *zone;
@property (strong) NSString *group;
@property (strong) NSString *scene;
@property (strong) NSString *UUID;
@property (assign) MDIOSFavoriteType favoriteType;

@end
