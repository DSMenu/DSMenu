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
        [self.netServiceBrowser searchForServicesOfType:@"_http._tcp." inDomain:@"local"];
        
        self.mDNSServices = [NSMutableArray array];
        self.dontUpdate = NO;
    }
    return self;
}

- (void)awakeFromNib {
    [self.titleTextField setStringValue:NSLocalizedString(@"preferenceMainTopTitle", @"Preference Main Title")];
    [self.serverAddressLabel setStringValue:NSLocalizedString(@"preferenceMainAddressLabel", @"Preference Address Label")];
    [self.tokenLabel setStringValue:NSLocalizedString(@"preferenceMainTokenLabel", @"Preference Address Label")];
    
    [self tokenDidChange];

    
    if([MDDSSManager defaultManager].useIPAddress)
    {
        self.addressTextField.stringValue = [MDDSSManager defaultManager].host;
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

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSNetService *netService = [self.mDNSServices objectAtIndex:rowIndex];
    return [netService.name stringByAppendingString:@".local"];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notif {
    if(self.dontUpdate || self.tableView.selectedRow == -1) { return; }

    NSNetService *netService = [self.mDNSServices objectAtIndex:self.tableView.selectedRow];
    [[MDDSSManager defaultManager] setAndPersistHost:[netService.name stringByAppendingString:@".local"]];
    [MDDSSManager defaultManager].useIPAddress = NO;
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

#pragma mark - RHPreferencesViewControllerProtocol

-(NSString*)identifier{
    return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage{
    return [NSImage imageNamed:@"preferences_main"];
}
-(NSString*)toolbarItemLabel{
    return NSLocalizedString(@"MainPreferences", @"MainPreferences Label");
}

-(NSView*)initialKeyView{
    return self.emailTextField;
}

@end
