//
//  MDIOSFavoriteTableViewCell.m
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSFavoriteTableViewCell.h"
#import "MDDSSManager.h"

@implementation MDIOSFavoriteTableViewCell

- (void)labelTaped:(UIButton *)sender
{
    if(!self.widgetMode)
    {
        if(self.favorite.favoriteType == MDIOSFavoriteTypeZonePreset)
        {
            NSUInteger aIndex = [self.labelBackgroundViews indexOfObject:sender];
            UILabel *label = [self.labels objectAtIndex:aIndex];
            NSString *originalText = label.text;
            
            
            [UIView animateWithDuration:0.2 animations:^{
                label.text = [NSString stringWithFormat:@"calling %@", NSLocalizedString(( [NSString stringWithFormat:@"group%@scene%d",  self.favorite.group,self.favorite.scene.intValue]), @"")];
                [self calculateSizes];
            }];
            
            [[MDDSSManager defaultManager] callScene:self.favorite.scene zoneId:self.favorite.zone groupID:self.favorite.group callback:^(NSDictionary *json, NSError *error)
             {
                 label.text = originalText;
                 [self calculateSizes];
             }];
        }
        else
        {
            [super labelTaped:sender];
        }
    }
}

- (BOOL)isOffItem
{
    return [MDDSHelper isOffScene:self.favorite.scene];
}

@end
