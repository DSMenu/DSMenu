//
//  DMConsumptionView.m
//  dSMetering
//
//  Created by Jonas Schnelli on 11.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSConsumptionView.h"
#import "MDDSSConsumptionManager.h"
#import "MDConsumptionLineView.h"
#import "MDConsumptionTextView.h"

@interface MDIOSConsumptionView ()
@property MDConsumptionLineView *lineView;
@property MDConsumptionTextView *textView;
@property MDConsumptionTextView *textViewTime;
@property UIImageView *circleImage;
@property NSDateFormatter *formatter;
@end

@implementation MDIOSConsumptionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self localInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self localInit];
    }
    return self;
}



- (void)localInit
{
    self.backgroundColor = [UIColor clearColor];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"HH:mm"];
    
    self.lineView = [[MDConsumptionLineView alloc] initWithFrame:CGRectMake(0,0,1,self.bounds.size.height)];
    self.textView = [[MDConsumptionTextView alloc] initWithFrame:CGRectMake(0,0,100,25)];
    self.textViewTime = [[MDConsumptionTextView alloc] initWithFrame:CGRectMake(0,0,100,25)];
    self.textViewTime.textColor = [NSColor_OR_UIColor blackColor];
    
    [self addSubview:self.lineView];
    [self addSubview:self.textView];
    [self addSubview:self.textViewTime];
    
    self.circleImage = nil;
    
#if TARGET_OS_IPHONE
    self.circleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,16,16)];
    [self.circleImage setImage:[UIImage imageNamed:@"cchart_highlight"]];
#else
    self.circleImage = [[NSImageView alloc] initWithFrame:CGRectMake(0,0,16,16)];
    [self.circleImage setImage:[NSImage imageNamed:@"cchart_highlight"]];
    
    // track mouse
    NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options: (NSTrackingMouseMoved | NSTrackingActiveAlways) owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
    
    // initially hide elements
    
#endif
    [self addSubview:self.circleImage];
    [self setVisibleState:YES];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.lineView.frame = CGRectMake(0,0,1,self.bounds.size.height);
}

#if TARGET_OS_IPHONE
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *anyTouch = [touches anyObject];
    CGPoint mouseLoc = [anyTouch locationInView:self.superview.superview];
    double wValue = 0;
    double timeVal = 0;
    CGFloat y = self.frame.size.height-[[MDDSSConsumptionManager defaultManager] heightForXValue:mouseLoc.x size:self.frame.size wValue:&wValue time:&timeVal];
    
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
    self.textView.frame = CGRectMake(mouseLoc.x+xDeltaLabel, y-30, self.textView.frame.size.width, self.textView.frame.size.height);
    self.textViewTime.frame = CGRectMake(mouseLoc.x, self.frame.size.height-30, self.textViewTime.frame.size.width, self.textViewTime.frame.size.height);
    
    BOOL vState = NO;
    if(timeVal == 0)
    {
        vState = YES;
    }
    [self setVisibleState:vState];
}
#else

#endif

- (void)setVisibleState:(BOOL)vState
{
    [self.textViewTime setHidden:vState];
    [self.circleImage setHidden:vState];
    [self.textView setHidden:vState];
    [self.lineView setHidden:vState];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform flipVertical = CGAffineTransformMake(
                                                           1, 0, 0, -1, 0, self.frame.size.height
                                                           );
    CGContextConcatCTM(context, flipVertical);
    
    [[MDDSSConsumptionManager defaultManager] drawHistoryOnContext:context size:self.frame.size];
}


@end
