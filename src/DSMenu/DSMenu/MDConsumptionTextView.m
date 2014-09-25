//
//  MDConsumptionTextView.m
//  DSMenu
//
//  Created by Jonas Schnelli on 15.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDConsumptionTextView.h"

@implementation MDConsumptionTextView
@synthesize textToShow=_textToShow;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = [NSColor_OR_UIColor whiteColor];
        // Initialization code here.
    }
    return self;
}

- (void)setTextToShow:(NSString *)textToShow
{
    _textToShow = textToShow;
    
#if TARGET_OS_IPHONE
    [self setNeedsDisplay];
#else
    [self setNeedsDisplay:YES];
#endif
}

- (NSString *)textToShow
{
    return _textToShow;
}


- (void)drawRect:(CGRect)dirtyRect
{
    CGContextRef context = nil;
    [super drawRect:dirtyRect];
#if TARGET_OS_IPHONE
    context = UIGraphicsGetCurrentContext();
    CGAffineTransform flipVertical = CGAffineTransformMake(
                                                           1, 0, 0, -1, 0, self.frame.size.height
                                                           );
    CGContextConcatCTM(context, flipVertical);
    
#else
    NSGraphicsContext *nsGraphicsContext    = [NSGraphicsContext currentContext];
    context                    = (CGContextRef) [nsGraphicsContext graphicsPort];
#endif
    CGContextSelectFont(context, "Helvetica-Light", 10, kCGEncodingMacRoman);
    CGContextSetFillColorWithColor(context, [self.textColor CGColor]);
    CGContextShowTextAtPoint(context, 0,1,  [self.textToShow cStringUsingEncoding:NSUTF8StringEncoding], self.textToShow.length);
}

@end
