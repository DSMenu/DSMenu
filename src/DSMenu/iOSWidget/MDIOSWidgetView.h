//
//  MDIOSWidgetView.h
//  DSMenu
//
//  Created by Jonas Schnelli on 23.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDIOSFavorite.h"

@interface MDIOSWidgetView : UIControl
@property (strong) MDIOSFavorite *favorite;
@property (strong) UIActivityIndicatorView *loadingIndicator;
- (instancetype)initWithFrame:(CGRect)frame andFavorite:(MDIOSFavorite *)favorite;
@end

