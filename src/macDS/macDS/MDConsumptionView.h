//
//  MDEnergyView.h
//  macDS
//
//  Created by Jonas Schnelli on 09.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MDConsumptionView : NSView
- (void)setValues:(NSDictionary *)values dSMs:(NSArray *)dSMs;
@end
