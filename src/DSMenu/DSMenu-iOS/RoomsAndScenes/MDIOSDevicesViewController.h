//
//  MDIOSDevicesViewController.h
//  DSMenu
//
//  Created by Jonas Schnelli on 29.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSBaseTableViewController.h"
#import "MDIOSBaseViewController.h"

@interface MDIOSDevicesViewController : MDIOSBaseTableViewController
@property (strong) IBOutlet UISlider *deviceValueSlider;
@property (strong) IBOutlet UIActivityIndicatorView *deviceValueSliderWheel;
@property (strong) IBOutlet UISwitch *deviceSwitch;
@property (strong) IBOutlet UIActivityIndicatorView *deviceSwitchWheel;
@property (strong) IBOutlet NSDictionary *device;
@property (strong) IBOutlet UILabel *currentScene;
@property (strong) IBOutlet UILabel *currentValue;
@end
