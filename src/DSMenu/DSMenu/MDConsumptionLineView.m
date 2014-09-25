//
//  MDConsumptionLineView.m
//  DSMenu
//
//  Created by Jonas Schnelli on 15.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDConsumptionLineView.h"

@implementation MDConsumptionLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)drawRect:(CGRect)dirtyRect {
#if TARGET_OS_IPHONE
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, dirtyRect);
#else
    [[NSColor_OR_UIColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
#endif
}

@end
