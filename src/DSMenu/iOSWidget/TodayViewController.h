//
//  TodayViewController.h
//  iOSWidget
//
//  Created by Jonas Schnelli on 20.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "Constantes.h"
#import "Notifications.h"
#import "ErrorCodes.h"

#import "MDDSHelper.h"
#import "MDDSSManager.h"


@interface TodayViewController : UIViewController
@property (strong) IBOutlet UIView *mainView;
@property (strong) IBOutlet UILabel *noFavoritesLabel;
@property (assign) BOOL hasDSSManagerAvailable;
@end
