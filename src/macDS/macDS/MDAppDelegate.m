//
//  MDAppDelegate.m
//  macDS
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDAppDelegate.h"
#import "MDDSSManager.h"

@interface MDAppDelegate ()
@property (strong) NSStatusItem * statusItem;
@property (assign) IBOutlet NSMenu *statusMenu;
@end

@implementation MDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    // make a global menu (extra menu) item
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    self.statusMenu.delegate = self;
    [self.statusItem setTitle:@""];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setAction:@selector(statusItemClicked)];
    
    [self.statusItem setImage:[NSImage imageNamed:@"status_bar_icon"]];
}

- (void)statusItemClicked
{
    [[MDDSSManager defaultManager] loginApplication:@"f0e037b369db3b22d03390f1cb8a931c475aca9c1a556f26cde89b03849c334a"];
}

@end
