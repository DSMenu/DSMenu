//
//  MDConsumptionLineView.m
//  macDS
//
//  Created by Jonas Schnelli on 15.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDConsumptionLineView.h"

@implementation MDConsumptionLineView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
