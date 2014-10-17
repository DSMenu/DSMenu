//
//  DMRoomTableViewCell.h
//  dSMetering
//
//  Created by Jonas Schnelli on 16.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

/**
 * \ingroup iOS
 */

#import <UIKit/UIKit.h>

/**
 *  MDIOSConsumptionTableViewCell
 *  class representing a single room cell in the rooms view controller
 */
@interface MDIOSRoomTableViewCell : UITableViewCell
@property (strong) NSString *zoneId;
@property (strong) IBOutlet UIView *colorBadge;
@property (strong) IBOutlet UILabel *mainLabel;
@property (strong) IBOutlet UIView *labelsView;
@property (strong) UILabel *firstLabel;
@property (strong) UIView *firstLabelView;

@property (strong) UILabel *loadingLabel;
@property (strong) UIView *loadingLabelBackgroundView;

@property (strong) NSMutableArray *labels;
@property (strong) NSMutableArray *labelBackgroundViews;

@property (strong) NSArray *availableGroups;

- (void)buildLabels:(NSArray *)groupNumbers;

@end
