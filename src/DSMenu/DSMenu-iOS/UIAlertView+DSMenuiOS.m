//
//  UIAlertView+DSMenuiOS.m
//  DSMenu
//
//  Created by Jonas Schnelli on 24.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <objc/runtime.h>
#import "UIAlertView+DSMenuiOS.h"

@interface DSMenuAlertViewWrapper : NSObject <UIAlertViewDelegate>

@property (copy) void(^completionBlock)(UIAlertView *alertView, NSInteger buttonIndex);

@end

@implementation DSMenuAlertViewWrapper

#pragma mark - UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.completionBlock)
        self.completionBlock(alertView, buttonIndex);
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView
{
    // Just simulate a cancel button click
    if (self.completionBlock)
        self.completionBlock(alertView, alertView.cancelButtonIndex);
}

-(void)didPresentAlertView:(UIAlertView *)alertView
{
    UITextField *passwordField = [alertView textFieldAtIndex:1];
    if(passwordField && passwordField.secureTextEntry == YES)
    {
        [passwordField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
    }
}

@end


static const char kDSMenuAlertViewWrapper;
@implementation UIAlertView (DSMenuiOS)

- (void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion
{
    DSMenuAlertViewWrapper *alertWrapper = [[DSMenuAlertViewWrapper alloc] init];
    alertWrapper.completionBlock = completion;
    self.delegate = alertWrapper;
    
    // Set the wrapper as an associated object
    objc_setAssociatedObject(self, &kDSMenuAlertViewWrapper, alertWrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Show the alert as normal
    [self show];
}

@end
