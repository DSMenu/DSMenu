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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)lightPressed:(id)sender
{
    
    [[MDDSSManager defaultManager] callScene:@"5" zoneId:self.zoneId groupID:@"1" callback:^(NSDictionary *json, NSError *error)
     {
         
     }];
    
}

- (IBAction)shadowPressed:(id)sender
{
    
}

@end
