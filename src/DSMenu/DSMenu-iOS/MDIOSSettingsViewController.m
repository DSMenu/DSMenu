//
//  DMSecondViewController.m
//  dSMetering
//
//  Created by Jonas Schnelli on 11.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSSettingsViewController.h"
#import "MDDSSManager.h"

typedef enum DMSettingsViewControllerState {
    DMSettingsViewControllerStateRemoteConnectivityForm = 0,
    DMSettingsViewControllerStateRemoteConnectivityOK = 1,
    DMSettingsViewControllerStateManual = 2
} DMSettingsViewControllerState;

@interface MDIOSSettingsViewController ()
@property NSNetServiceBrowser *netServiceBrowser;
@property NSMutableArray *mDNSServices;
@property BOOL dontUpdate;
@end

@implementation MDIOSSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    [self.netServiceBrowser setDelegate:self];
    [self.netServiceBrowser searchForServicesOfType:@"_http._tcp." inDomain:@"local"];
    self.dontUpdate = NO;
    self.mDNSServices = [NSMutableArray array];
    
    [self setViewState:DMSettingsViewControllerStateRemoteConnectivityForm];
    
    NSString *remoteConnectivityUsername = [MDDSSManager defaultManager].remoteConnectivityUsername;
    if(remoteConnectivityUsername && [remoteConnectivityUsername isKindOfClass:[NSString class]])
    {
        self.emailField.text = remoteConnectivityUsername;
    }
    
    if([MDDSSManager defaultManager].useRemoteConnectivity)
    {
        [self.networkActivityIndicator startAnimating];
        [self setViewState:DMSettingsViewControllerStateRemoteConnectivityOK];
        
        self.connectionStateInfoText.text = NSLocalizedString(@"tryToConnectMessage", @"Try to connect message in preference");
        [[MDDSSManager defaultManager] getVersion:^(NSDictionary *json, NSError *error){
            if(!error)
            {
                self.connectionStateInfoText.text = @"";
                
                self.statusImage.hidden = NO;
                self.statusImage.image = [UIImage imageNamed:@"checkmark.png"];
            }
            else
            {
                self.connectionStateInfoText.text = NSLocalizedString(@"connectionFailed", @"connection established message in settings");
                
                self.statusImage.hidden = NO;
                self.statusImage.image = [UIImage imageNamed:@"checkmark.png"];
            }
        }];
        
        [self.networkActivityIndicator stopAnimating];
    }
    else
    {
        if([MDDSSManager defaultManager].host && [MDDSSManager defaultManager].host.length > 0)
        {
            [self setViewState:DMSettingsViewControllerStateManual];
            [self.connectionTypeSegmentedControl setSelectedSegmentIndex:1];
        }
    }
}


#pragma mark - mDNS / Bonjour Stack

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    [self.mDNSServices addObject:aNetService];
    [self.localHostMDNSList reloadData];
    
    DDLogVerbose(@"%@ %@", [aNetService.name stringByAppendingString:@".local"], [MDDSSManager defaultManager].host);
    
    if([[aNetService.name stringByAppendingString:@".local"] isEqualToString:[MDDSSManager defaultManager].host])
    {
        for(int i=0;i<self.mDNSServices.count;i++)
        {
            NSNetService *anotherService = [self.mDNSServices objectAtIndex:i];
            if([anotherService isEqual:aNetService])
            {
                self.dontUpdate = YES;
                [self.localHostMDNSList selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
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

#pragma mark UITableView stack
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mDNSServices.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSNetService *netService = [self.mDNSServices objectAtIndex:indexPath.row];
    // Then setup properties on the cellView based on the column
    cell.textLabel.text = [netService.name stringByAppendingString:@".local"];
    
    if([[netService.name stringByAppendingString:@".local"] isEqualToString:[MDDSSManager defaultManager].host])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [(UIActivityIndicatorView *)cell.accessoryView startAnimating];
    
    NSNetService *netService = [self.mDNSServices objectAtIndex:indexPath.row];
    

    [[MDDSSManager defaultManager] checkHost:[netService.name stringByAppendingString:@".local"] callback:^(BOOL status)
     {
         [(UIActivityIndicatorView *)cell.accessoryView stopAnimating];
         if(status)
         {
             cell.accessoryView = nil;
             cell.accessoryType = UITableViewCellAccessoryCheckmark;
             [[MDDSSManager defaultManager] setAndPersistHost:[netService.name stringByAppendingString:@".local"]];
             [MDDSSManager defaultManager].useIPAddress = NO;
             [MDDSSManager defaultManager].useRemoteConnectivity = NO;
             [self.localHostMDNSList reloadData];
         }
     }];
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark IBActions

- (IBAction)backgroundTap:(id)sender
{
    [self.passwordField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.manualIPField resignFirstResponder];
}

#pragma UITextFieldDelegate stack

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.emailField)
    {
        [self.passwordField becomeFirstResponder];
    }
    else if(textField == self.passwordField)
    {
        [self.passwordField resignFirstResponder];
    }
    else if(textField == self.manualIPField)
    {
        [self.manualIPField resignFirstResponder];
    }
    return YES;
}

- (void)setViewState:(DMSettingsViewControllerState)state
{
    if(state == DMSettingsViewControllerStateRemoteConnectivityForm || state == DMSettingsViewControllerStateRemoteConnectivityOK)
    {
        self.useManualIP.hidden = YES;
        self.useManualIPLabel.hidden = YES;
        self.manualIPField.hidden = YES;
        self.selectHostLabel.hidden = YES;
        self.localHostMDNSList.hidden = YES;
        self.connectLocalButton.hidden = YES;
        
        self.statusImage.hidden = NO;
        self.localStatusImage.hidden = YES;
    }
    else
    {
        self.useManualIP.hidden = NO;
        self.useManualIPLabel.hidden = NO;
        self.manualIPField.hidden = NO;
        self.selectHostLabel.hidden = NO;
        self.localHostMDNSList.hidden = NO;
        self.connectLocalButton.hidden = NO;
        self.statusImage.hidden = YES;
        
        self.localStatusImage.hidden = YES;
    }
    
    if(state == DMSettingsViewControllerStateRemoteConnectivityForm)
    {
        self.emailField.hidden = NO;
        self.passwordField.hidden = NO;
        self.connectButton.hidden = NO;
        self.disconnectButton.hidden = YES;
        self.connectionStateInfoText.text = @"";
        self.statusImage.hidden = YES;
    }
    else if(state == DMSettingsViewControllerStateRemoteConnectivityOK)
    {
        self.emailField.hidden = NO;
        self.passwordField.hidden = YES;
        self.connectButton.hidden = YES;
        self.disconnectButton.hidden = NO;
    }
    else if(state == DMSettingsViewControllerStateManual)
    {
        self.emailField.hidden = YES;
        self.passwordField.hidden = YES;
        self.connectButton.hidden = YES;
        self.disconnectButton.hidden = YES;
    }
}

- (IBAction)segmentedControlDidChange:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 1)
    {
        [self setViewState:DMSettingsViewControllerStateManual];
    }
    else if(sender.selectedSegmentIndex == 0)
    {
        if([MDDSSManager defaultManager].useRemoteConnectivity)
        {
            [self setViewState:DMSettingsViewControllerStateRemoteConnectivityOK];
        }
        else {
            [self setViewState:DMSettingsViewControllerStateRemoteConnectivityForm];
        }
    }
}

#pragma Login Management
- (IBAction)localLoginPressed:(id)sender
{
    [self.localConnectionActivityIndicator startAnimating];
    self.localStatusImage.hidden = YES;
    [[MDDSSManager defaultManager] checkHost:self.manualIPField.text callback:^(BOOL status)
     {
         self.localStatusImage.hidden = NO;
         
         [self.localConnectionActivityIndicator stopAnimating];
         if(status)
         {
             self.localStatusImage.image = [UIImage imageNamed:@"checkmark.png"];
             [[MDDSSManager defaultManager] setAndPersistHost:self.manualIPField.text];
             [MDDSSManager defaultManager].useIPAddress = YES;
             [MDDSSManager defaultManager].useRemoteConnectivity = NO;
         }
         else
         {
             self.localStatusImage.image = [UIImage imageNamed:@"alert.png"];
         }
     }];
    
}

- (IBAction)loginPressed:(id)sender
{
    [self.passwordField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.networkActivityIndicator startAnimating];
    self.connectionStateInfoText.text = NSLocalizedString(@"tryToConnectMessage", @"Try to connect message in preference");
    self.connectionStateInfoText.textColor = [UIColor darkGrayColor];
    self.connectionStateInfoText.hidden = NO;
    self.statusImage.hidden = YES;
    
    
    [[MDDSSManager defaultManager] checkRemoteConnectivityFor:self.emailField.text password:self.passwordField.text callback:^(NSDictionary *json, NSError *error)
     {
         if(error == NO && json && [json objectForKey:@"Response"] != [NSNull null] && [[json objectForKey:@"Response"] objectForKey:@"RelayLink"])
         {
             // we have connection
             NSURL *url = [NSURL URLWithString:[[json objectForKey:@"Response"] objectForKey:@"RelayLink"]];
             
             [[MDDSSManager defaultManager] setAndPersistHost:url.host];
             [MDDSSManager defaultManager].useRemoteConnectivity = YES;
             [[MDDSSManager defaultManager] setRemoteConnectivityUsername:self.emailField.text];
             
             [self.localHostMDNSList reloadData];
             
             NSString *token = [[json objectForKey:@"Response"] objectForKey:@"Token"];
             
             [[MDDSSManager defaultManager] loginApplication:token callBlock:^(NSDictionary *json, NSError *error)
              {
                  if([json objectForKey:@"result"] && [[json objectForKey:@"result"] objectForKey:@"token"])
                  {
                      [self.networkActivityIndicator stopAnimating];
                      self.statusImage.hidden = NO;
                      self.statusImage.image = [UIImage imageNamed:@"checkmark.png"];
                      self.connectionStateInfoText.hidden = YES;
                    
                      [self setViewState:DMSettingsViewControllerStateRemoteConnectivityOK];
                      
                      [[NSNotificationCenter defaultCenter] postNotificationName:kMD_NOTIFICATION_APPTOKEN_DID_CHANGE object:nil];
                  }
              }
              ];
         }
         else
         {
             [self.networkActivityIndicator stopAnimating];
             self.statusImage.hidden = NO;
             self.statusImage.image = [UIImage imageNamed:@"alert.png"];
             self.connectionStateInfoText.hidden = NO;
             self.connectionStateInfoText.text = NSLocalizedString(@"connectionFailed", @"connection established message in settings");
             
             self.connectionStateInfoText.textColor = [UIColor redColor];
         }
     }
     ];
}

- (IBAction)disconnectPressed:(id)sender
{
    [[MDDSSManager defaultManager] setAndPersistHost:@""];
    [MDDSSManager defaultManager].useRemoteConnectivity = NO;
    
    [self setViewState:DMSettingsViewControllerStateRemoteConnectivityForm];
}

@end
