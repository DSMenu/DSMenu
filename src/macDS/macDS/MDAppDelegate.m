//
//  MDAppDelegate.m
//  macDS
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDAppDelegate.h"
#import "MDDSSManager.h"
#import "MDZoneMenuItem.h"
#import "MDDeviceMenuItem.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

#include "LaunchAtLoginController.h"

#import "MDMainPreferencesViewController.h"
#import "MDDetailPreferencesViewController.h"
#import "RHPreferencesWindowController.h"

#define kMACDE_PREV_VERSIONS_STARTED_UD_KEY @"MacDsPrevStartupVersions"

@interface MDAppDelegate ()
@property (strong) NSStatusItem * statusItem;
@property (assign) IBOutlet NSMenu *statusMenu;
@property (retain) RHPreferencesWindowController *preferencesWindowController;
@property (strong) NSError * currentError;

@property (assign) MDAppState appState;
@property (strong) NSTimer *refreshTimer;
@end

@implementation MDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    self.appState = MDAppStateBootstrapping;
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    [fileLogger setRollingFrequency:60 * 60 * 24];   // roll every day
    [fileLogger setMaximumFileSize:1024 * 1024 * 2]; // max 2mb file size
    [fileLogger.logFileManager setMaximumNumberOfLogFiles:7];
    
    [DDLog addLogger:fileLogger];
    
    DDLogVerbose(@"Logging is setup (\"%@\")", [fileLogger.logFileManager logsDirectory]);
    
    
    // make a global menu (extra menu) item
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    self.statusMenu.delegate = self;
    [self.statusItem setTitle:@""];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setImage:[NSImage imageNamed:@"status_bar_icon"]];
    
    
    // if first start, check if user likes that the app will run after login
    [self checkRunAtStartup];
    
    
    // init dSS Layer
    self.currentError = nil;
    [MDDSSManager defaultManager].appName = @"macDS";
    if([MDDSSManager defaultManager].host == nil || [MDDSSManager defaultManager].host.length == 0)
    {
        // open preferences when no dSS is configured
        
        [self showPreferences:self];
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:NSLocalizedString(@"pleaseConfigureDSS",@"Alert Message When Application Need To Configure a DSS")];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        
    }
    [self refreshMenu];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMenu) name:kMD_NOTIFICATION_HOST_DID_CHANGE object:nil];
}

- (void)refreshMenu
{
    self.currentError = nil;
    [self refreshStructureMainThread:nil];
    if(![MDDSSManager defaultManager].hasApplicationToken)
    {
        [[MDDSSManager defaultManager] requestApplicationToken:^(NSDictionary *json, NSError *error){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kMD_NOTIFICATION_APPTOKEN_DID_CHANGE object:nil];
            
            // open safari when user need's to give access to registered token
            [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: [@"https://" stringByAppendingString:[MDDSSManager defaultManager].host]]];
            
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:NSLocalizedString(@"applicationTokenRequested",@"Alert Message When Application Token was requested")];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            
            // perform a faster refresh in case user gave access to token
            self.appState = MDAppStateWaitingForAccess;
            self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerKick:) userInfo:nil repeats:YES];
        }];
    }
    else
    {
        [self performSelectorInBackground:@selector(refreshStructure) withObject:nil];
    }
}

- (void)refreshStructure
{
    // create autoreleasepool for async menu update in case use presses mouse down (on statusmenuitem) while updating in background
    
    @autoreleasepool {
        [[MDDSSManager defaultManager] getVersion:^(NSDictionary *json, NSError *error){
            self.currentError = error;
            if(error && error.code == MD_ERROR_AUTH_ERROR)
            {
                self.appState = MDAppStateAuthError;
                return;
            }
            else {
                [[MDDSSManager defaultManager] getStructureWithCustomSceneNames:^(NSDictionary *json, NSError *error){
                    self.currentError = error;
                    
                    if(error && error.code == MD_ERROR_AUTH_ERROR)
                    {
                        self.appState = MDAppStateAuthError;
                        [self performSelectorOnMainThread:@selector(refreshStructureMainThread:) withObject:nil waitUntilDone:YES];
                        return;
                    }
                    else
                    {
                        self.appState = MDAppStateIdel;
                        [self.refreshTimer invalidate];
                        self.refreshTimer = nil;

                        [self performSelectorOnMainThread:@selector(refreshStructureMainThread:) withObject:json waitUntilDone:YES];
                    }
                }];
            }
        }];
        
        
        CFRunLoopRun();
    }
}


- (void)refreshStructureMainThread:(NSDictionary *)json
{
    // empty menu
    [self.statusMenu removeAllItems];
    
    if([MDDSSManager defaultManager].dSSVersionString)
    {
        // create a nice two line string of the dSS Version Feedback
        NSString *versionString = [MDDSSManager defaultManager].dSSVersionString;
        NSArray *parts = [versionString componentsSeparatedByString:@" "];
        NSMutableString *niceString = [[NSMutableString alloc] initWithCapacity:1000];
        if(parts.count > 2)
        {
            int cnt = 0;
            for(NSString *part in parts)
            {
                [niceString appendString:part];
                (cnt == 2) ? [niceString appendString:@"\n"] : [niceString appendString:@" "];;
                cnt++;
            }
        }
        NSMenuItem *versionInfoItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
        
        NSMutableAttributedString* str =[[NSMutableAttributedString alloc]initWithString:niceString];
        [str setAttributes: @{ NSForegroundColorAttributeName: [NSColor lightGrayColor], NSFontAttributeName : [NSFont systemFontOfSize:10] } range: NSMakeRange(0, [str length])];
        [versionInfoItem setAttributedTitle: str];
        
        [self.statusMenu addItem:versionInfoItem];
        [self.statusMenu addItem:[NSMenuItem separatorItem]];
    }
    
    if(json) {
        
        //sort zones
        NSArray *zones = [[[json objectForKey:@"result"] objectForKey:@"apartment"] objectForKey:@"zones"];
        zones = [zones sortedArrayUsingComparator:^(id obj1, id obj2) {
            if(![obj1 objectForKey:@"name"] || [[obj1 objectForKey:@"name"] length] <= 0)
            {
                return NSOrderedDescending;
            }
            else if(![obj2 objectForKey:@"name"] || [[obj2 objectForKey:@"name"] length] <= 0)
            {
                return NSOrderedAscending;
            }
            return [[obj1 objectForKey:@"name"] compare:[obj2 objectForKey:@"name"]];
        }];
        
        // build zone menus
        for(NSDictionary *zoneDict in zones)
        {
            if([[zoneDict objectForKey:@"id"] intValue] == 0)
            {
                // logical ID 0 room
                continue;
            }
            MDZoneMenuItem *menuItem = [MDZoneMenuItem menuItemWithZoneDictionary:zoneDict];
            menuItem.target = self;
            menuItem.action = @selector(zoneMenuItemClicked:);
            [self.statusMenu addItem:menuItem];
        }
    }
    else {
        if(self.currentError)
        {
            NSMenuItem *loadingItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"errorConnecting", @"Error Connection Menu Item Title") action:nil keyEquivalent:@""];
            [self.statusMenu addItem:loadingItem];
        }
        else {
            NSMenuItem *loadingItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"loading", @"Loading Menu Item Title") action:nil keyEquivalent:@""];
            [self.statusMenu addItem:loadingItem];
        }
    }
    
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *preferenceItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"preferences", @"Preferences Menu Item Title") action:@selector(showPreferences:) keyEquivalent:@""];
    [self.statusMenu addItem:preferenceItem];
    
    NSMenuItem *refreshItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"refresh", @"Refresh Menu Item Title") action:@selector(refreshMenu) keyEquivalent:@""];
    [self.statusMenu addItem:refreshItem];
    
    [self.statusMenu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"quit", @"Quit Menu Item Title") action:@selector(terminate:) keyEquivalent:@""];
    quitItem.target = [NSApplication sharedApplication];
    [self.statusMenu addItem:quitItem];
}

#pragma mark - Menu Item callbacks

- (void)zoneMenuItemClicked:(id)sender
{
    MDZoneMenuItem *zoneMenuItem = (MDZoneMenuItem *)sender;
    
    NSString *scene = @"0";
    NSString *group = @"1";
    
    if(zoneMenuItem.clickedSubmenu) {
        scene = [NSString stringWithFormat:@"%ld", zoneMenuItem.clickedSubmenu.tag];
        group = [NSString stringWithFormat:@"%ld", zoneMenuItem.clickedSubmenu.group];
    }
    
    if(zoneMenuItem.clickType == MDZoneMenuItemClickTypeScene)
    {
        [[MDDSSManager defaultManager] callScene:scene zoneId:zoneMenuItem.zoneId groupID:group callback:^(NSDictionary *json, NSError *error){
            
        }];
    }
    else if(zoneMenuItem.clickType == MDZoneMenuItemClickTypeDevice)
    {
        MDDeviceMenuItem *deviceMenuItem = (MDDeviceMenuItem *)zoneMenuItem.clickedSubmenu;
        
        if(deviceMenuItem.turnOnOffMode)
        {
            if(zoneMenuItem.clickedSubmenu.tag)
            {
                [[MDDSSManager defaultManager] turnOnDeviceId:deviceMenuItem.dsid callback:^(NSDictionary *json, NSError *error){
                    
                }];
            }
            else
            {
                [[MDDSSManager defaultManager] turnOffDeviceId:deviceMenuItem.dsid callback:^(NSDictionary *json, NSError *error){
                    
                }];
            }
            
        }
        else {
            [[MDDSSManager defaultManager] callScene:scene deviceId:deviceMenuItem.dsid callback:^(NSDictionary *json, NSError *error){
                
            }];
        }

    }
    
}

#pragma mark - Preferences Stack
-(IBAction)showPreferences:(id)sender{
    //if we have not created the window controller yet, create it now
    if (!self.preferencesWindowController){
        MDMainPreferencesViewController *mainPreferences = [[MDMainPreferencesViewController alloc] init];
       MDDetailPreferencesViewController *detailsPreferences = [[MDDetailPreferencesViewController alloc] init];
        
        NSArray *controllers = [NSArray arrayWithObjects:
                                mainPreferences,
                                detailsPreferences,
                                nil];
        
        self.preferencesWindowController = [[RHPreferencesWindowController alloc] initWithViewControllers:controllers andTitle:NSLocalizedString(@"Preferences", @"Preferences Window Title")];
    }
    
    [self.preferencesWindowController showWindow:self];
    [self.preferencesWindowController.window orderFrontRegardless];
    
}

#pragma mark - NSTimer callbacks
- (void)timerKick:(id)sender
{
    [self refreshMenu];
}

#pragma mark - Migration / Version / first Start

- (void)checkRunAtStartup
{
    // Get current version ("Bundle Version") from the default Info.plist file
    NSString *currentVersion = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSArray *prevStartupVersions = [[NSUserDefaults standardUserDefaults] arrayForKey:kMACDE_PREV_VERSIONS_STARTED_UD_KEY];
    if (prevStartupVersions == nil)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"yesButton", @"Yes Button")];
        [alert addButtonWithTitle:NSLocalizedString(@"noButton", @"No Button")];
        [alert setMessageText:NSLocalizedString(@"launchAtStartupQuestion", @"launch at startup question")];
        [alert setInformativeText:@""];
        [alert setAlertStyle:NSWarningAlertStyle];
        NSInteger alertResult = [alert runModal];
        if(alertResult == NSAlertFirstButtonReturn) {
            self.launchAtStartup = YES;
        }
        else {
            self.launchAtStartup = NO;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:currentVersion] forKey:kMACDE_PREV_VERSIONS_STARTED_UD_KEY];
    }
    else
    {
        if (![prevStartupVersions containsObject:currentVersion])
        {
            // add the current version to the startup version array
            NSMutableArray *updatedPrevStartVersions = [NSMutableArray arrayWithArray:prevStartupVersions];
            [updatedPrevStartVersions addObject:currentVersion];
            [[NSUserDefaults standardUserDefaults] setObject:updatedPrevStartVersions forKey:kMACDE_PREV_VERSIONS_STARTED_UD_KEY];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - auto launch controlling stack

- (BOOL)launchAtStartup
{
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL state = [launchController launchAtLogin];
    launchController = nil;
    return state;
}

- (void)setLaunchAtStartup:(BOOL)aState
{
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [launchController setLaunchAtLogin:aState];
    launchController = nil;
}

@end
