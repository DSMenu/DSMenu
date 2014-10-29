//
//  DMConsumptionTableViewCell.m
//  dSMetering
//
//  Created by Jonas Schnelli on 09.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSConsumptionTableViewCell.h"

@implementation MDIOSConsumptionTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.consumptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,10,100,20)];
        self.consumptionLabel.textColor = [UIColor whiteColor];
        self.consumptionLabel.font = [UIFont systemFontOfSize:20];
        
        self.consumptionLabelBackgroundColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.2 alpha:1.0];
        
        self.backgroundSquare = [[UIView alloc] init];
        self.backgroundSquare.backgroundColor = self.consumptionLabelBackgroundColor;
        
        self.backgroundSquare.layer.cornerRadius = 2;
        self.backgroundSquare.layer.masksToBounds = YES;
        
        [self.contentView addSubview:self.backgroundSquare];
        [self.contentView addSubview:self.consumptionLabel];
        
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = [UIColor darkGrayColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundSquare.backgroundColor = self.consumptionLabelBackgroundColor;
    
    CGFloat labelHeight = 20;
    self.consumptionLabel.frame = CGRectMake(10,round((self.bounds.size.height-20)/2.0), 70, labelHeight);
    
    CGRect aSize = [self.consumptionLabel textRectForBounds:CGRectMake(0,0,1000,40) limitedToNumberOfLines:1];
    NSLog(@"%f", aSize.size.width);
    self.consumptionLabel.frame = CGRectMake(20,round((self.bounds.size.height-20)/2.0), aSize.size.width+5, labelHeight);
    
    self.backgroundSquare.frame = CGRectMake(15,round((self.bounds.size.height-25)/2.0), aSize.size.width+10, labelHeight+5);
    
    CGFloat delta = 100.0;
    
    self.textLabel.frame = CGRectMake(delta,0,self.bounds.size.width-delta, self.bounds.size.height);
    //self.textLabel.textColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.backgroundSquare.backgroundColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.2 alpha:1.0];
}

@end
