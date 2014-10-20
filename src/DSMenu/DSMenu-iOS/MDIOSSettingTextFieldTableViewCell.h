//
//  MDIOSSettingTextFieldTableViewCell.h
//  DSMenu
//
//  Created by Jonas Schnelli on 20.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDIOSSettingTextFieldTableViewCell : UITableViewCell <UITextFieldDelegate>
@property (strong) IBOutlet UITextField *textField;
@property (strong) IBOutlet UILabel *contraintsHelperLabel;
@property (assign) NSInteger textFieldColumns;
@property (assign) CGFloat spaceLeft;
@end
