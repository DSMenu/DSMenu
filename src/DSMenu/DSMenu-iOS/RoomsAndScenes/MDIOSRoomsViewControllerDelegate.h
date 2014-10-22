//
//  MDIOSRoomsViewControllerDelegate.h
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#ifndef DSMenu_MDIOSRoomsViewControllerDelegate_h
#define DSMenu_MDIOSRoomsViewControllerDelegate_h

#import "MDIOSWidgetAction.h"

@class MDIOSRoomsViewController;
@protocol MDIOSRoomsViewControllerDelegate

- (void)roomsOrScenesViewController:(UIViewController *)controller didSelectAction:(MDIOSWidgetAction *)action;

@end

#endif
