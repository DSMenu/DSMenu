//
//  MDIOSScenePresetTableViewCell.m
//  DSMenu
//
//  Created by Jonas Schnelli on 19.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSScenePresetTableViewCell.h"

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
        
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIImage *favImage;
//        if(self.isFavorized)
//        {
//            favImage = [UIImage imageNamed:@"PUFavoriteOn.png"];
//        }
//        else
//        {
//            favImage = [UIImage imageNamed:@"PUFavoriteOff.png"];
//        }
//        [button setImage:favImage forState:UIControlStateNormal];
//        button.frame = CGRectMake(0,0,favImage.size.width,favImage.size.height);
//        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
//        self.accessoryView = button;
    }
}

- (void)buttonTapped:(id)sender
{
    self.isFavorized = !self.isFavorized;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
