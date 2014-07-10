//
//  MDEnergyView.m
//  macDS
//
//  Created by Jonas Schnelli on 09.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDConsumptionView.h"
#import "MDDSSConsumptionManager.h"

@interface MDConsumptionView ()
@property (strong) NSDictionary *values;
@property (strong) NSArray *dSMs;
@end

@implementation MDConsumptionView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
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
    self.values = [values copy];
    self.dSMs = [dSMs copy];
    [self setNeedsDisplay:YES];
}

@end
