//
//  RHAboutViewController.m
//  RHPreferencesTester
//
//  Created by Richard Heard on 17/04/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//

#import "MDMainPreferencesViewController.h"
#import "MDDSSManager.h"

@interface MDMainPreferencesViewController ()
@property NSNetServiceBrowser *netServiceBrowser;
@property NSMutableArray *mDNSServices;
@property BOOL dontUpdate;
@end

@implementation MDMainPreferencesViewController



-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:@"MDMainPreferencesViewController" bundle:nibBundleOrNil];
    if (self){
        // Initialization code here.
        
        self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
        [self.netServiceBrowser setDelegate:self];
        [self.netServiceBrowser searchForServicesOfType:@"_dssweb._tcp." inDomain:@"local"];
        
        self.mDNSServices = [NSMutableArray array];
        self.dontUpdate = NO;
    }
    return self;
}

- (void)awakeFromNib {
    
    /* i18n */
    [self.titleTextField setStringValue:NSLocalizedString(@"preferenceMainTopTitle", @"Preference Main Title")];
    [self.serverAddressLabel setStringValue:NSLocalizedString(@"preferenceMainAddressLabel", @"Preference Address Label")];
    [self.tokenLabel setStringValue:NSLocalizedString(@"preferenceMainTokenLabel", @"Preference Address Label")];
    self.manualIPCheckbox.title =NSLocalizedString(@"preferenceMainAddressCustomIPLabel", @"Preference Checkbox manual Address Label");
    
    [self.remoteConnectivityLoginButton setTitle:NSLocalizedString(@"loginButton", @"Preference Remote Connectivity Login Button")];
    
    [self.remoteConnectivityDisconnectButton setTitle:NSLocalizedString(@"disconnectButton", @"Preference Remote Connectivity Disconnect Button")];
    
    self.remoteConnectivityPasswordLabel.stringValue = NSLocalizedString(@"passwordLabel", @"Preference Password Label");
    self.remoteConnectivityUsernameLabel.stringValue = NSLocalizedString(@"usernameLabel", @"Preference Username Label");
    
    NSTabViewItem *aItem = [self.tabView tabViewItemAtIndex:0];
    [aItem setLabel:NSLocalizedString(@"localConnectionTab", @"First Tab Item Label")];
    
    aItem = [self.tabView tabViewItemAtIndex:1];
    [aItem setLabel:NSLocalizedString(@"remoteConnectivityTab", @"Second Tab Item Label")];
    
    [self tokenDidChange];

    
    [self.addressTextField setEnabled:NO];
    if([MDDSSManager defaultManager].useIPAddress)
    {
        [self.addressTextField setEnabled:YES];
        self.addressTextField.stringValue = [MDDSSManager defaultManager].host;
    }
    
    [self.remoteConnectivityDisconnectButton setHidden:YES];
    [self.remoteConnectivityStateText setHidden:YES];
    self.remoteConnectivityStateImage.image = [NSImage imageNamed:@"NSStatusNone"];
    
    if([MDDSSManager defaultManager].useRemoteConnectivity)
    {
        [self.tabView selectLastTabViewItem:self];
        
        NSString *remoteConnectivityUsername = [MDDSSManager defaultManager].remoteConnectivityUsername;
        if(remoteConnectivityUsername && [remoteConnectivityUsername isKindOfClass:[NSString class]])
        {
            self.remoteConnectivityUsernameField.stringValue = remoteConnectivityUsername;
        }
        
        self.remoteConnectivityStateImage.image = [NSImage imageNamed:@"NSStatusNone"];
        [self.remoteConnectivityProgressIndicator startAnimation:self];
        self.remoteConnectivityStateText.stringValue = NSLocalizedString(@"tryToConnectMessage", @"Try to connect message in preference");
        [[MDDSSManager defaultManager] getVersion:^(NSDictionary *json, NSError *error){
            [self.remoteConnectivityProgressIndicator stopAnimation:self];
            if(!error)
            {
                
                self.remoteConnectivityStateText.stringValue = NSLocalizedString(@"connectionSuccessfull", @"connection established message in settings");
                
                self.remoteConnectivityStateImage.image = [NSImage imageNamed:@"NSStatusAvailable"];
                [self.remoteConnectivityDisconnectButton setHidden:NO];
                
                [self.remoteConnectivityPasswordField setHidden:YES];
                [self.remoteConnectivityPasswordLabel setHidden:YES];
                [self.remoteConnectivityLoginButton setHidden:YES];
            }
            else
            {
                self.remoteConnectivityStateText.stringValue = NSLocalizedString(@"connectionFailed", @"connection error message in preference");
                
                self.remoteConnectivityStateImage.image = [NSImage imageNamed:@"NSStatusUnavailable"];
            }
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenDidChange) name:kMD_NOTIFICATION_APPTOKEN_DID_CHANGE object:nil];
}

- (void)tokenDidChange
{
    self.tokenField.stringValue = ([MDDSSManager defaultManager].applicationToken) ? [MDDSSManager defaultManager].applicationToken : @"";
}

#pragma mark - mDNS / Bonjour Stack

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    [self.mDNSServices addObject:aNetService];
    [self.tableView reloadData];
    
    DDLogVerbose(@"%@ %@", [aNetService.name stringByAppendingString:@".local"], [MDDSSManager defaultManager].host);
    
    if([[aNetService.name stringByAppendingString:@".local"] isEqualToString:[MDDSSManager defaultManager].host])
    {
        for(int i=0;i<self.mDNSServices.count;i++)
        {
            NSNetService *anotherService = [self.mDNSServices objectAtIndex:i];
            if([anotherService isEqual:aNetService])
            {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:i];
                self.dontUpdate = YES;
                [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
                self.dontUpdate = NO;
            }
        }
    }
    
    DDLogDebug(@"%@ %@", aNetService.name, [NSNumber numberWithLong:[aNetService port]]);
    DDLogDebug(@"%@", [[NSString alloc] initWithData:aNetService.TXTRecordData encoding:NSUTF8StringEncoding]);
}

-(void)netServiceDidResolveAddress:(NSNetService *)sender
{
    DDLogDebug( ([NSString stringWithFormat:@"Service resolved. Host name: %@ Port number: %@", [sender hostName], [NSNumber numberWithLong:[sender port]]]), @"" );
}

#pragma mark - TableView Datasource / Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.mDNSServices.count;
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"MainCell"]) {
        NSNetService *netService = [self.mDNSServices objectAtIndex:row];
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        cellView.textField.stringValue = [netService.name stringByAppendingString:@".local"];
        
        if([[netService.name stringByAppendingString:@".local"] isEqualToString:[MDDSSManager defaultManager].host])
        {
            cellView.imageView.objectValue = [NSImage imageNamed:NSImageNameMenuOnStateTemplate];
            self.dontUpdate = YES;
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:row];
            [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
            self.dontUpdate = NO;
        }
        else
        {
            cellView.imageView.objectValue = nil;
        }
        
        return cellView;
    } else {
        NSAssert1(NO, @"Unhandled table column identifier %@", identifier);
    }
    return nil;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSNetService *netService = [self.mDNSServices objectAtIndex:rowIndex];
    return [netService.name stringByAppendingString:@".local"];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notif {
    if(self.dontUpdate || self.tableView.selectedRow == -1) { return; }

    NSNetService *netService = [self.mDNSServices objectAtIndex:self.tableView.selectedRow];
    
    [self.progressIndicator startAnimation:self];
    [[MDDSSManager defaultManager] checkHost:[netService.name stringByAppendingString:@".local"] callback:^(BOOL status)
     {
         [self.progressIndicator stopAnimation:self];
         if(status)
         {
             [[MDDSSManager defaultManager] setAndPersistHost:[netService.name stringByAppendingString:@".local"]];
             [MDDSSManager defaultManager].useIPAddress = NO;
             [MDDSSManager defaultManager].useRemoteConnectivity = NO;
             [self.tableView reloadData];
         }
     }];
    
    
}

#pragma mark - NSTextField Delegate

- (void)controlTextDidChange:(NSNotification *)notification
{
    [self.tableView deselectAll:self];
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    if(control == self.addressTextField)
    {
        [[MDDSSManager defaultManager] setAndPersistHost:[control stringValue]];
        [MDDSSManager defaultManager].useIPAddress = YES;
        [MDDSSManager defaultManager].useRemoteConnectivity = NO;
    }
    if(control == self.tokenField)
    {
        [MDDSSManager defaultManager].applicationToken = [control stringValue];
    }
    
    return YES;
}

- (IBAction)reset:(id)sender
{
    [[MDDSSManager defaultManager] resetToDefaults];
}

#pragma mark - Manual IP

- (BOOL)manualIP
{
    return [MDDSSManager defaultManager].useIPAddress;
}

- (void)setManualIP:(BOOL)aState
{
    [MDDSSManager defaultManager].useIPAddress = aState;
    [self.addressTextField setEnabled:aState];
    if(aState == YES)
    {
        [self.tableView deselectAll:self];
    }
}

#pragma mark - remoteConnectivityLogin

- (IBAction)loginPressed:(id)sender
{
    
    self.remoteConnectivityStateImage.image = [NSImage imageNamed:@"NSStatusNone"];
    [self.remoteConnectivityProgressIndicator startAnimation:self];
    self.remoteConnectivityStateText.stringValue = NSLocalizedString(@"tryToConnectMessage", @"Try to connect message in preference");
    
    [[MDDSSManager defaultManager] checkRemoteConnectivityFor:[self.remoteConnectivityUsernameField stringValue] password:[self.remoteConnectivityPasswordField stringValue] callback:^(NSDictionary *json, NSError *error)
     {
         [self.remoteConnectivityProgressIndicator stopAnimation:self];
         if(error == NO && json && [json objectForKey:@"Response"] != [NSNull null] && [[json objectForKey:@"Response"] objectForKey:@"RelayLink"])
         {
             self.remoteConnectivityStateText.stringValue = NSLocalizedString(@"connectionSuccessfull", @"connection established message in settings");
             
             [self.remoteConnectivityDisconnectButton setHidden:NO];
             [self.remoteConnectivityPasswordField setHidden:YES];
             [self.remoteConnectivityPasswordLabel setHidden:YES];
             [self.remoteConnectivityLoginButton setHidden:YES];
             [self.remoteConnectivityStateText setHidden:NO];
             
             self.remoteConnectivityStateImage.image = [NSImage imageNamed:@"NSStatusAvailable"];
             
             // we have connection
             NSURL *url = [NSURL URLWithString:[[json objectForKey:@"Response"] objectForKey:@"RelayLink"]];
             
             [[MDDSSManager defaultManager] setAndPersistHost:url.host];
             [MDDSSManager defaultManager].useRemoteConnectivity = YES;
             [[MDDSSManager defaultManager] setRemoteConnectivityUsername:[self.remoteConnectivityUsernameField stringValue]];
         }
         else
         {
             [self.remoteConnectivityStateText setHidden:NO];
             self.remoteConnectivityStateText.stringValue = NSLocalizedString(@"connectionFailed", @"connection established message in settings");
             
             self.remoteConnectivityStateImage.image = [NSImage imageNamed:@"NSStatusUnavailable"];
         }
     }
     ];
}

- (IBAction)disconnectPressed:(id)sender
{
    [[MDDSSManager defaultManager] setAndPersistHost:@""];
    [MDDSSManager defaultManager].useRemoteConnectivity = NO;
    
    self.remoteConnectivityStateImage.image = [NSImage imageNamed:@"NSStatusNone"];
    
    [self.remoteConnectivityDisconnectButton setHidden:YES];
    [self.remoteConnectivityPasswordField setHidden:NO];
    [self.remoteConnectivityPasswordLabel setHidden:NO];
    [self.remoteConnectivityLoginButton setHidden:NO];
    [self.remoteConnectivityStateText setHidden:YES];
}

#pragma mark - RHPreferencesViewControllerProtocol

-(NSString*)identifier{
    return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage{
    return [NSImage imageNamed:@"preferences_connection"];
}
-(NSString*)toolbarItemLabel{
    return NSLocalizedString(@"MainPreferences", @"MainPreferences Label");
}

-(NSView*)initialKeyView{
    return self.tableView;
}

@end
