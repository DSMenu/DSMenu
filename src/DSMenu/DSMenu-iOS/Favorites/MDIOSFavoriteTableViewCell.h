//
//  MDIOSFavoriteTableViewCell.h
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSRoomTableViewCell.h"

@interface MDIOSFavoriteTableViewCell : MDIOSRoomTableViewCell
@property (strong) IBOutlet UILabel *subtitle;
@property (assign) BOOL widgetMode;
@end
