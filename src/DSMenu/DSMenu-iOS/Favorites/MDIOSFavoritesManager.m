//
//  MDIOSFavoritesManager.m
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSFavoritesManager.h"
#import "Constantes.h"

#define kMDIOS_UD_FAVORITES_KEY @"MDIOSFavorites"
static MDIOSFavoritesManager *defaultManager;

@interface MDIOSFavoritesManager()
@property (strong) NSMutableArray *favorites;
@property (readonly) NSUserDefaults *userDefaultsProxy;
@end


@implementation MDIOSFavoritesManager


+ (MDIOSFavoritesManager *)defaultManager
{
    if(!defaultManager)
    {
        defaultManager = [[MDIOSFavoritesManager alloc] init];
    }
    return defaultManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:kDSMENU_APP_GROUP_IDENTIFIER];
        NSData *possibleData = [self.userDefaultsProxy objectForKey:kMDIOS_UD_FAVORITES_KEY];
        if(!possibleData || ![possibleData isKindOfClass:[NSData class]])
        {
            self.favorites = [NSMutableArray array];
        }
        else
        {
            self.favorites = [[NSKeyedUnarchiver unarchiveObjectWithData:possibleData] mutableCopy];
        }
    }
    return self;
}

- (MDIOSFavorite *)favoriteForZone:(NSString *)zone group:(NSString *)group scene:(NSString *)scene
{
    if([zone isKindOfClass:[NSNumber class]])
    {
        zone = [(NSNumber *)zone stringValue];
    }
    if([group isKindOfClass:[NSNumber class]])
    {
        group = [(NSNumber *)group stringValue];
    }
    if([scene isKindOfClass:[NSNumber class]])
    {
        scene = [(NSNumber *)scene stringValue];
    }
    
    for(MDIOSFavorite *fav in self.favorites)
    {
        
        if(fav.favoriteType == MDIOSFavoriteTypeZonePreset)
        {
            if([fav.zone isEqualToString:zone] && [fav.group isEqualToString:group] && [fav.scene isEqualToString:scene])
            {
                return fav;
            }
        }
        else if(group == nil && scene == nil && fav.favoriteType == MDIOSFavoriteTypeZone)
        {
            if([fav.zone isEqualToString:zone])
            {
                return fav;
            }
        }
    }
    return nil;
}

- (MDIOSFavorite *)favoriteForUUID:(NSString *)uuid
{
    for(MDIOSFavorite *favorite in self.favorites)
    {
        if([favorite.UUID isEqualToString:uuid])
        {
            return favorite;
        }
    }
    return nil;
}

- (void)addFavorit:(MDIOSFavorite *)favorite
{
    if(favorite.UUID == nil)
    {
        favorite.UUID = [self generateUUID];
    }
    // check if favorite already exists
    if([self.favorites indexOfObject:favorite] == NSNotFound)
    {
        [self.favorites addObject:favorite];
        [self persist];
    }
}

- (void)removeFavorite:(MDIOSFavorite *)favorite
{
    [self.favorites removeObject:favorite];
    [self persist];
}

- (void)removeFavoriteAtIndex:(NSInteger)index
{
    [self.favorites removeObjectAtIndex:index];
    [self persist];
}

- (void)exchangeFavoriteFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    [self.favorites exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    [self persist];
}

- (NSArray *)allFavorites
{
    return self.favorites;
}

- (void)persist
{
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kDSMENU_APP_GROUP_IDENTIFIER];
    NSURL *containerURLFile = [containerURL URLByAppendingPathComponent:kDSMENU_SECURITY_NAME_FOR_FAVORITES];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.favorites];
    [data writeToURL:containerURLFile atomically:YES];
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSDictionary *attribs = @{NSFileProtectionKey : NSFileProtectionNone};
    NSError *unprotectError = nil;
    
    BOOL unprotectSuccess = [fm setAttributes:attribs
                                 ofItemAtPath:[containerURL path]
                                        error:&unprotectError];
    if (!unprotectSuccess) {
        NSLog(@"Unable to remove protection from file! %@", unprotectError);
    }
    
    [self.userDefaultsProxy setObject:[NSKeyedArchiver archivedDataWithRootObject:self.favorites] forKey:kMDIOS_UD_FAVORITES_KEY];
    [self.userDefaultsProxy synchronize];
}

- (NSUserDefaults *)userDefaultsProxy
{
    if(self.currentUserDefaults)
    {
        return self.currentUserDefaults;
    }
    return [NSUserDefaults standardUserDefaults];
}

- (NSString *)generateUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

@end
