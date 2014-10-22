//
//  MDIOSScenePresetTableViewCell.m
//  DSMenu
//
//  Created by Jonas Schnelli on 19.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSScenePresetTableViewCell.h"
#import "MDIOSFavoritesManager.h"

@implementation MDIOSScenePresetTableViewCell


@synthesize isFavorized=_isFavorized;
@synthesize isLoading=_isLoading;


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isFavorized = NO;
    }
    return self;
}

- (void)setIsFavorized:(BOOL)isFavorized
{
    _isFavorized = isFavorized;
    [self updateAccessoryView];
}

- (BOOL)isFavorized
{
    return _isFavorized;
}

- (void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
    [self updateAccessoryView];
}

- (BOOL)isLoading
{
    return _isLoading;
}


- (void)updateAccessoryView
{
    if(self.isLoading)
    {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator startAnimating];
        self.accessoryView = activityIndicator;
    }
    else
    {
        self.accessoryView = nil;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *favImage;
        if(self.isFavorized)
        {
            favImage = [UIImage imageNamed:@"ReviewSheetStarFull.png"];
        }
        else
        {
            favImage = [UIImage imageNamed:@"ReviewSheetStarEmptyNew.png"];
        }
        [button setImage:favImage forState:UIControlStateNormal];
        button.frame = CGRectMake(0,0,favImage.size.width,favImage.size.height);
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = button;
    }
}

- (void)buttonTapped:(id)sender
{
    self.isFavorized = !self.isFavorized;
    
    MDIOSFavorite *favorite = [[MDIOSFavorite alloc] init];
    favorite.zone   = [(NSNumber *)self.zone stringValue];
    favorite.group  = [(NSNumber *)self.group stringValue];
    favorite.scene  = [(NSNumber *)self.scene stringValue];
    favorite.favoriteType = MDIOSFavoriteTypeZonePreset;
    
    if(self.isFavorized)
    {
        [[MDIOSFavoritesManager defaultManager] addFavorit:favorite];
    }
    else
    {
        [[MDIOSFavoritesManager defaultManager] removeFavorite:favorite];
    }
}

- (void)checkFavoriteState
{
    if([[MDIOSFavoritesManager defaultManager] favoriteForZone:self.zone group:self.group scene:self.scene]){
        self.isFavorized = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
