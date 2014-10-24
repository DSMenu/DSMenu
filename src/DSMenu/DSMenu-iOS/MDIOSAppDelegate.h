//
//  AppDelegate.h
//  DSMenu-iOS
//
//  Created by Jonas Schnelli on 17.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

/**
 * \ingroup iOS
 */

#import <UIKit/UIKit.h>

@interface MDIOSAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong) NSMutableArray *consumptionData;
@property (strong) NSDictionary *structure;
- (void)startPollingData;


@end

