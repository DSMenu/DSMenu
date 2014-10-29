//
//  MDIOSFavoriteTableViewCell.m
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSFavoriteTableViewCell.h"

@implementation MDIOSFavoriteTableViewCell

- (void)labelTaped:(UIButton *)sender
{
    if(!self.widgetMode)
    {
        [super labelTaped:sender];
    }
}

@end
