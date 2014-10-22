//
//  DMConsumptionTableViewCell.h
//  dSMetering
//
//  Created by Jonas Schnelli on 09.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

/**
 * \ingroup iOS
 */

#import <UIKit/UIKit.h>

/**
 *  MDIOSConsumptionTableViewCell
 *  This class represents a dsm consumption cell
 */
@interface MDIOSConsumptionTableViewCell : UITableViewCell

@property (strong) UILabel *consumptionLabel;
@property (strong) UIView *backgroundSquare;
@property (strong) UIColor *consumptionLabelBackgroundColor;

@end
