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
        
        self.favorizeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-55,0,55,self.contentView.frame.size.height)];
        self.favorizeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 3, 0);
        self.favorizeButton.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        self.favorizeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.favorizeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.favorizeButton];
        [self updateFavoriteState];
        
    }
    return self;
}

- (void)setIsFavorized:(BOOL)isFavorized
{
    _isFavorized = isFavorized;
    [self updateFavoriteState];
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

- (void)updateFavoriteState
{
    UIImage *favImage = nil;
    
    if(self.isFavorized)
    {
        favImage = [UIImage imageNamed:@"ReviewSheetStarFull.png"];
    }
    else
    {
        favImage = [UIImage imageNamed:@"ReviewSheetStarEmptyNew.png"];
    }
    [self.favorizeButton setImage:favImage forState:UIControlStateNormal];
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
