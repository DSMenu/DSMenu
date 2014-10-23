//
//  MDIOSWidgetView.m
//  DSMenu
//
//  Created by Jonas Schnelli on 23.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSWidgetView.h"

@implementation MDIOSWidgetView

- (instancetype)initWithFrame:(CGRect)frame andFavorite:(MDIOSFavorite *)favorite
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 4.0;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 0.8;
    
        self.backgroundColor = [UIColor clearColor];
        
        self.favorite = favorite;
        
        UILabel *labelT = [[UILabel alloc] initWithFrame:CGRectMake(22, 4, self.frame.size.width-26, 16)];
        labelT.backgroundColor = [UIColor clearColor];
        labelT.textColor = [UIColor whiteColor];
        labelT.font = [UIFont systemFontOfSize:14];
        labelT.text = favorite.title;
        [self addSubview:labelT];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(22, 20, self.frame.size.width-26, 16)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:11];
        label.text = favorite.subtitle;
        [self addSubview:label];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:(NSLocalizedString(@"group_%d.png", @"")), self.favorite.group.intValue]]];
        if(self.favorite.scene.intValue == 0)
        {
            imgView.image = [UIImage imageNamed:@"off_menu_icon.png"];
        }
        
        imgView.frame = CGRectMake(5,round(self.frame.size.height/2.0 - imgView.image.size.height/2.0), imgView.image.size.width, imgView.image.size.height);
        [self addSubview:imgView];
        
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
        
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        self.loadingIndicator.frame = CGRectMake(self.frame.size.width-3-self.loadingIndicator.frame.size.width, round(self.frame.size.height/2.0 - self.loadingIndicator.frame.size.height/2.0), self.loadingIndicator.frame.size.width, self.loadingIndicator.frame.size.height);
        self.loadingIndicator.hidesWhenStopped = YES;
        [self addSubview:self.loadingIndicator];
        
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    if(highlighted)
    {
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
    }
    else
    {
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
