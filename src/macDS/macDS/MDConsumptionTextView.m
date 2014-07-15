//
//  MDConsumptionTextView.m
//  macDS
//
//  Created by Jonas Schnelli on 15.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDConsumptionTextView.h"

@implementation MDConsumptionTextView
@synthesize textToShow=_textToShow;
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = [NSColor whiteColor];
        // Initialization code here.
    }
    return self;
}

- (void)setTextToShow:(NSString *)textToShow
{
    _textToShow = textToShow;
    [self setNeedsDisplay:YES];
}

- (NSString *)textToShow
{
    return _textToShow;
}


- (void)drawRect:(NSRect)dirtyRect
{
    NSGraphicsContext *nsGraphicsContext    = [NSGraphicsContext currentContext];
    CGContextRef context                    = (CGContextRef) [nsGraphicsContext graphicsPort];
    
    
    CGContextSelectFont(context, "Helvetica-Light", 10, kCGEncodingMacRoman);
    CGContextSetFillColorWithColor(context, [self.textColor CGColor]);
    CGContextShowTextAtPoint(context, 0,1,  [self.textToShow cStringUsingEncoding:NSUTF8StringEncoding], self.textToShow.length);
    
    [super drawRect:dirtyRect];
}

@end
