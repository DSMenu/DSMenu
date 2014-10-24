//
//  UIAlertView+DSMenuiOS.h
//  DSMenu
//
//  Created by Jonas Schnelli on 24.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (DSMenuiOS)
- (void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion;
@end
