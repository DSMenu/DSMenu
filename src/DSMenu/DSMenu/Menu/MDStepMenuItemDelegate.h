//
//  MDStepMenuItemDelegate.h
//  DSMenu
//
//  Created by Jonas Schnelli on 25.09.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

@class MDStepMenuItem;
@protocol MDStepMenuItemDelegate

-(void)stepMenuItem:(MDStepMenuItem *)stepMenuItem increment:(BOOL)value;

@end
