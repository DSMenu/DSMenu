//
//  AppDelegate.m
//  DSMenuHelper
//
//  Created by Jonas Schnelli on 02.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    NSString *appPath = [[[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent]  stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    NSString *binaryPath = [[NSBundle bundleWithPath:appPath] executablePath];
    BOOL state = [[NSWorkspace sharedWorkspace] launchApplication:binaryPath];
    [NSApp terminate:nil];
}

@end
