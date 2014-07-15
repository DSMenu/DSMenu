//
//  MDConsumptionView.m
//  macDS
//
//  Created by Jonas Schnelli on 09.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDConsumptionView.h"
#import "MDDSSConsumptionManager.h"
#import "MDConsumptionLineView.h"
#import "MDConsumptionTextView.h"

@interface MDConsumptionView ()
@property MDConsumptionLineView *lineView;
@property MDConsumptionTextView *textView;
@property MDConsumptionTextView *textViewTime;
@property NSImageView *circleImage;
@property NSDateFormatter *formatter;
@end

@implementation MDConsumptionView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.formatter = [[NSDateFormatter alloc] init];
        [self.formatter setDateFormat:@"HH:mm"];
        
        self.lineView = [[MDConsumptionLineView alloc] initWithFrame:CGRectMake(50,0,1,self.frame.size.height)];
        self.textView = [[MDConsumptionTextView alloc] initWithFrame:CGRectMake(0,0,100,25)];
        self.textViewTime = [[MDConsumptionTextView alloc] initWithFrame:CGRectMake(0,0,100,25)];
        self.textViewTime.textColor = [NSColor blackColor];
        
        [self addSubview:self.lineView];
        [self addSubview:self.textView];
        [self addSubview:self.textViewTime];
        
        self.circleImage = [[NSImageView alloc] initWithFrame:CGRectMake(0,0,16,16)];
        [self.circleImage setImage:[NSImage imageNamed:@"cchart_highlight"]];
        [self addSubview:self.circleImage];
        
        // track mouse
        NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options: (NSTrackingMouseMoved | NSTrackingActiveAlways) owner:self userInfo:nil];
        [self addTrackingArea:trackingArea];
        
        // initially hide elements
        [self setVisibleState:NO];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSGraphicsContext    *    nsGraphicsContext    = [NSGraphicsContext currentContext];
    CGContextRef            context        = (CGContextRef) [nsGraphicsContext graphicsPort];
    
    [[MDDSSConsumptionManager defaultManager] drawHistoryOnContext:context size:self.frame.size];
    [super drawRect:dirtyRect];
}

- (void)setValues:(NSDictionary *)values dSMs:(NSArray *)dSMs
{
    [self setNeedsDisplay:YES];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
   
    
    double wValue = 0;
    double timeVal = 0;
    CGFloat y = [[MDDSSConsumptionManager defaultManager] heightForXValue:mouseLoc.x size:self.frame.size wValue:&wValue time:&timeVal];
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:timeVal];
    NSString *startTimeString = [self.formatter stringFromDate:date];
    self.textViewTime.textToShow = startTimeString;
    
    self.textView.textToShow = [NSString stringWithFormat:@"%d W", (int)round(wValue)];
    

    CGFloat xDeltaLabel = 5;
    if(mouseLoc.x > self.frame.size.width*0.73)
    {
        xDeltaLabel = -30;
    }
    
    self.circleImage.frame = CGRectMake(mouseLoc.x-(self.circleImage.frame.size.width/2.0), y-(self.circleImage.frame.size.height/2.0), self.circleImage.frame.size.width, self.circleImage.frame.size.height);
    self.lineView.frame = CGRectMake(mouseLoc.x, self.lineView.frame.origin.y, self.lineView.frame.size.width, self.lineView.frame.size.height);
    self.textView.frame = CGRectMake(mouseLoc.x+xDeltaLabel, y+5, self.textView.frame.size.width, self.textView.frame.size.height);
    self.textViewTime.frame = CGRectMake(mouseLoc.x, self.lineView.frame.origin.y+5, self.textViewTime.frame.size.width, self.textViewTime.frame.size.height);
    
    BOOL vState = NO;
    if(timeVal == 0)
    {
        vState = YES;
    }
    [self setVisibleState:vState];
    
}

- (void)setVisibleState:(BOOL)vState
{
    [self.textViewTime setHidden:vState];
    [self.circleImage setHidden:vState];
    [self.textView setHidden:vState];
    [self.lineView setHidden:vState];
}

@end
