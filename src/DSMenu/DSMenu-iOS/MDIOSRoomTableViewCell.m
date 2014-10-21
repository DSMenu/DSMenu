//
//  DMRoomTableViewCell.m
//  dSMetering
//
//  Created by Jonas Schnelli on 16.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSRoomTableViewCell.h"
#import "MDDSSManager.h"

@implementation MDIOSRoomTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.colorBadge.backgroundColor = [UIColor clearColor];
    
    
}

- (void)buildLabels:(NSArray *)groupNumbers
{
    self.availableGroups = groupNumbers;
    
    [self.labelsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.labels = [NSMutableArray array];
    self.labelBackgroundViews = [NSMutableArray array];
    
    NSMutableArray *groups = [NSMutableArray array];
    for(NSString *groupNumber in groupNumbers)
    {
        NSString *title = NSLocalizedString(([NSString stringWithFormat:@"group%@", groupNumber]), @"");
        [groups addObject:@{@"title": title, @"group": groupNumber, @"textcolor": [UIColor whiteColor], @"bgcolor": [UIColor darkGrayColor]}];
    }
    
    for(NSDictionary *labelDict in groups)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,20)];
        label.text = [labelDict objectForKey:@"title"];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [labelDict objectForKey:@"textcolor"];
        
        [self.labels addObject:label];
        
        UIButton *labelBackgroundView = [[UIButton alloc] init];
        labelBackgroundView.backgroundColor = [labelDict objectForKey:@"bgcolor"];
        [labelBackgroundView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"group_%@.png", [labelDict objectForKey:@"group"]]] forState:UIControlStateNormal];
        labelBackgroundView.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        
        labelBackgroundView.layer.cornerRadius = 2.0;
        labelBackgroundView.layer.masksToBounds = YES;
        labelBackgroundView.tag = [[labelDict objectForKey:@"group"] intValue];
        [labelBackgroundView addTarget:self action:@selector(labelTaped:) forControlEvents:UIControlEventTouchUpInside];
        [self.labelBackgroundViews addObject:labelBackgroundView];
        
        [self.labelsView addSubview:labelBackgroundView];
        [self.labelsView addSubview:label];
    }
}

- (void)showLoading
{
    [self.labelsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.labels = [NSMutableArray array];
    self.labelBackgroundViews = [NSMutableArray array];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,20)];
    label.text = @"loading...";
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    
    [self.labels addObject:label];
    
    UIButton *labelBackgroundView = [[UIButton alloc] init];
    labelBackgroundView.backgroundColor = [UIColor darkGrayColor];
    
    labelBackgroundView.layer.cornerRadius = 2.0;
    labelBackgroundView.layer.masksToBounds = YES;
    labelBackgroundView.tag = 1000;
    [labelBackgroundView addTarget:self action:@selector(loadingLabelTaped:) forControlEvents:UIControlEventTouchUpInside];
    [self.labelBackgroundViews addObject:labelBackgroundView];
    
    [self.labelsView addSubview:labelBackgroundView];
    [self.labelsView addSubview:label];

}

- (void)loadingLabelTaped:(id)sender
{
//    [self buildLabels:self.availableGroups];
//    [self setNeedsLayout];
}

- (void)labelTaped:(UIButton *)sender
{
    NSString *group = [NSString stringWithFormat:@"%ld", sender.tag];
    if([MDDSSManager defaultManager].useLastCalledSceneCheck)
    {
        [[MDDSSManager defaultManager] lastCalledSceneInZoneId:self.zoneId groupID:group callback:^(NSDictionary *json, NSError *error)
         {
             if(!error && [json objectForKey:@"result"])
             {
                 NSString *scene = [[json objectForKey:@"result"] objectForKey:@"scene"];
                 int currentScene = [scene intValue];
                 int desiredScene = 0;
                 if(currentScene == 5)
                 {
                     desiredScene = 0;
                 }
                 else if(currentScene == 0 || currentScene >5)
                 {
                     desiredScene = 5;
                 }
                 
                 NSUInteger aIndex = [self.labelBackgroundViews indexOfObject:sender];
                 UILabel *label = [self.labels objectAtIndex:aIndex];
                 
                 [UIView animateWithDuration:0.5 animations:^{
                     
                     label.text = [NSString stringWithFormat:@"calling %@", NSLocalizedString(( [NSString stringWithFormat:@"group%@scene%d",  group,desiredScene]), @"")];
                     [self calculateSizes];
                     
                 }];
                 
                 NSString *sceneString = [NSString stringWithFormat:@"%d", desiredScene];
                 [[MDDSSManager defaultManager] callScene:sceneString zoneId:self.zoneId groupID:group callback:^(NSDictionary *json, NSError *error)
                  {
                      [self buildLabels:self.availableGroups];
                      [self calculateSizes];
                  }];
             }
         }];
        
        NSUInteger aIndex = [self.labelBackgroundViews indexOfObject:sender];
        UILabel *label = [self.labels objectAtIndex:aIndex];
        
        [UIView animateWithDuration:0.5 animations:^{
            label.text = @"loading state...";
            [self calculateSizes];
        }];
    }
    else
    {
        NSUInteger aIndex = [self.labelBackgroundViews indexOfObject:sender];
        UILabel *label = [self.labels objectAtIndex:aIndex];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            label.text = NSLocalizedString(( [NSString stringWithFormat:@"group%@scene5", group]), @"");
            [self calculateSizes];
            
        }];
        
        [[MDDSSManager defaultManager] callScene:@"5" zoneId:self.zoneId groupID:group callback:^(NSDictionary *json, NSError *error)
         {
             label.text = @"done";
             [self calculateSizes];
         }];
    }
    
    
    
    
}

- (void)calculateSizes
{
    if(self.availableGroups.count > 0)
    {
        int cnt = 0;
        CGFloat xOffset = 0;
        CGFloat xSpace = 4;
        CGFloat imageSpaceH = 12;
        CGFloat labelHeight = 16;
        for(UILabel *label in self.labels)
        {
            UIButton *backgroundView = [self.labelBackgroundViews objectAtIndex:cnt];
            CGRect calculatedSize = [label textRectForBounds:CGRectMake(0,0,1000,20) limitedToNumberOfLines:1];
            label.frame = CGRectMake(xOffset+4+imageSpaceH,0,calculatedSize.size.width,20);
            
            backgroundView.imageEdgeInsets = UIEdgeInsetsMake(0, -label.frame.size.width-2, 0, 0);
            
            backgroundView.frame = CGRectMake(xOffset+0,2,calculatedSize.size.width+8+imageSpaceH,labelHeight+2);
            xOffset+=backgroundView.frame.size.width+xSpace;
            cnt++;
        }
        
        self.mainLabel.frame = CGRectMake(self.mainLabel.frame.origin.x,10,self.mainLabel.frame.size.width,self.mainLabel.frame.size.height);
        self.labelsView.hidden = NO;
        
        self.labelsView.frame = CGRectMake(self.labelsView.frame.origin.x, self.labelsView.frame.origin.y, self.labelsView.frame.size.width, labelHeight+6);
    }
    else
    {
        self.mainLabel.frame = CGRectMake(self.mainLabel.frame.origin.x,0,self.mainLabel.frame.size.width,self.contentView.frame.size.height);
        self.labelsView.hidden = YES;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculateSizes];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)firstButton:(id)sender
{
//    [[MDDSSManager defaultManager] callScene:@"5" zoneId:self.zoneId groupID:@"1" callback:^(NSDictionary *json, NSError *error)
//     {
//         
//     }];
}

- (IBAction)secondButton:(id)sender
{
    
}

@end
