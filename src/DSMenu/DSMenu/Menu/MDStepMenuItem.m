//
//  MDDimSliderMenuItem.m
//  DSMenu
//
//  Created by Jonas Schnelli on 25.09.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDStepMenuItem.h"

@implementation MDStepMenuItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        NSView *menuItemView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 100, 25)];
        
        NSTextView *dimTextView = [[NSTextView alloc] initWithFrame:CGRectMake(20,0,50,20)];
        [dimTextView setString:NSLocalizedString(@"Dim", @"")];
        [dimTextView setBackgroundColor:[NSColor clearColor]];
        [dimTextView setSelectable:NO];
        [menuItemView addSubview:dimTextView];
        
        NSButton *button = [[NSButton alloc] initWithFrame:CGRectMake(15+34,3,20,20)];
        [button setImage:[NSImage imageNamed:@"dimDown"]];
        [button setButtonType:NSMomentaryChangeButton];
        [button setAlternateImage:[NSImage imageNamed:@"dimDownActive"]];
        [button setTitle:@""];
        [button setTarget:self];
        [button setAction:@selector(stepDown:)];
        [button setBordered:NO];
        [button setContinuous:YES];
        [menuItemView addSubview:button];
        
        button = [[NSButton alloc] initWithFrame:CGRectMake(35+34,3,20,20)];
        [button setImage:[NSImage imageNamed:@"dimUp"]];
        [button setButtonType:NSMomentaryChangeButton];
        [button setAlternateImage:[NSImage imageNamed:@"dimUpActive"]];
        [button setTitle:@""];
        [button setTarget:self];
        [button setContinuous:YES];
        [button setBordered:NO];
        [button setAction:@selector(stepUp:)];
        [menuItemView addSubview:button];
        
        [self setView:menuItemView];
    }
    return self;
}

- (void)stepUp:(id)sender
{
    self.incrementPressed = YES;
    [self.stepTarget stepMenuItem:self increment:YES];
}

- (void)stepDown:(id)sender
{
    self.incrementPressed = NO;
    [self.stepTarget stepMenuItem:self increment:NO];
}


@end
