//
//  MDIOSSettingsConnectionsViewController.m
//  DSMenu
//
//  Created by Jonas Schnelli on 20.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSSettingsConnectionsViewController.h"
#import "MDDSSManager.h"
#import "MDIOSSettingTextFieldTableViewCell.h"

#define kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_SECTION 0
#define kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_BUTTON_SECTION 1
#define kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION 2

@interface MDIOSSettingsConnectionsViewController ()
@property NSNetServiceBrowser *netServiceBrowser;
@property NSMutableArray *mDNSServices;
@property BOOL dontUpdate;
@end

@implementation MDIOSSettingsConnectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    [self.netServiceBrowser setDelegate:self];
    
    self.searchingMDNS = YES;
    NSTimer *timer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(searchEnd) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    self.dontUpdate = NO;
    self.mDNSServices = [NSMutableArray array];
    
    self.currentUsername = @"";
    self.currentPassword = @"";
    
    NSString *remoteConnectivityUsername = [MDDSSManager defaultManager].remoteConnectivityUsername;
    if(remoteConnectivityUsername && [remoteConnectivityUsername isKindOfClass:[NSString class]])
    {
        self.currentUsername = remoteConnectivityUsername;
    }
    
    if([MDDSSManager defaultManager].useRemoteConnectivity)
    {
        [[MDDSSManager defaultManager] getVersion:^(NSDictionary *json, NSError *error){
            self.checkConnection = NO;
            if(!error)
            {
                self.connectionError = NO;
            }
            else
            {
                self.connectionError = YES;
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - mDNS / Bonjour Stack

- (void)searchEnd
{
    self.searchingMDNS = NO;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    [self.mDNSServices addObject:aNetService];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    DDLogVerbose(@"%@ %@", [aNetService.name stringByAppendingString:@".local"], [MDDSSManager defaultManager].host);
    
    if([[aNetService.name stringByAppendingString:@".local"] isEqualToString:[MDDSSManager defaultManager].host])
    {
        for(int i=0;i<self.mDNSServices.count;i++)
        {
            NSNetService *anotherService = [self.mDNSServices objectAtIndex:i];
            if([anotherService isEqual:aNetService])
            {
                self.dontUpdate = YES;
//                [self.localHostMDNSList selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return @"mein.digitalStrom";
    }
    else if(section == kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION)
    {
        return @"local Connection";
    }
    else
    {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_BUTTON_SECTION)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,100)];
        return footerView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_SECTION)
    {
        return 1;
    }
    else if(section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_BUTTON_SECTION)
    {
        return 40;
    }
    else
    {
        return [super tableView:tableView heightForFooterInSection:section];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_SECTION)
    {
        if([MDDSSManager defaultManager].useRemoteConnectivity)
        {
            return 1;
        }
        return 2;
    }
    else if(section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_BUTTON_SECTION)
    {
        return 1;
    }
    else if(section == kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION)
    {
        if(self.showLocalConnection)
        {
            return 1+self.mDNSServices.count+1+self.searchingMDNS;
        }
        return 1;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if(indexPath.section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_SECTION)
    {
        MDIOSSettingTextFieldTableViewCell *cell2 = (MDIOSSettingTextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
        
        
        NSString *usernameLabel = @"Username";
        NSString *passwordLabel = @"Password";
        
        cell2.textLabel.text = usernameLabel;
        CGRect sizeUsername = [cell2.textLabel textRectForBounds:CGRectMake(0,0,1000,30) limitedToNumberOfLines:1];
        
        cell2.textLabel.text = passwordLabel;
        CGRect sizePassword = [cell2.textLabel textRectForBounds:CGRectMake(0,0,1000,30) limitedToNumberOfLines:1];
        
        if(sizePassword.size.width > sizeUsername.size.width)
        {
            cell2.contraintsHelperLabel.text = passwordLabel;
        }
        
        if(indexPath.row == 0)
        {
            cell2.textLabel.text = usernameLabel;
            cell2.textField.placeholder = NSLocalizedString(@"john@dooh.com", @"username placeholder");
            cell2.textField.tag = 1;
            cell2.accessoryView = nil;
        
            if(self.currentUsername)
            {
                cell2.textField.text = self.currentUsername;
                
                if(self.checkConnection == YES)
                {
                    cell2.accessoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    [(UIActivityIndicatorView *)cell2.accessoryView startAnimating];
                }
                else
                {
                    if(self.connectionError == NO)
                    {
                        if([MDDSSManager defaultManager].useRemoteConnectivity)
                        {
                            cell2.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
                        }
                    }
                    else
                    {
                        cell2.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert.png"]];
                    }
                }
            }
        }
        else
        {
            cell2.textLabel.text = passwordLabel;
            cell2.textField.placeholder = NSLocalizedString(@"your password", @"password placeholder");
            cell2.textField.tag = 2;
            cell2.textField.secureTextEntry = YES;
        }
        
        
        
        cell = (UITableViewCell *)cell2;
    }
    else if(indexPath.section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_BUTTON_SECTION)
    {
        cell.textLabel.text = @"Connect";
        cell.accessoryView = nil;
        cell.textLabel.textColor = BLUE_LINK_COLOR;
        cell.tag = 0;
        
        if([MDDSSManager defaultManager].useRemoteConnectivity)
        {
            cell.textLabel.text = @"Disconnect";
            cell.tag = 1;
            cell.textLabel.textColor = [UIColor colorWithRed:0.8 green:0.1 blue:0.1 alpha:1.0];
        }
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        if(self.tryToConnect) {
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            [activityIndicator startAnimating];
            cell.accessoryView = activityIndicator;
        }
    }
    else if(indexPath.section == kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION)
    {
        if(indexPath.row == 0)
        {
            cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"switchCell"];
            UISwitch *aSwitch = (UISwitch *)[cell.contentView viewWithTag:101];
            aSwitch.on = self.showLocalConnection;
            
            cell.textLabel.text = @"Local Connection";
        }
        else if(indexPath.row > 0 && indexPath.row < self.mDNSServices.count)
        {
            NSNetService *netService = [self.mDNSServices objectAtIndex:indexPath.row-1];
            
            cell.textLabel.text = netService.name;
        }
        else
        {
            if(self.searchingMDNS && indexPath.row == self.mDNSServices.count+1)
            {
                cell.textLabel.text = @"searching neibourhood...";
                cell.textLabel.font = [UIFont systemFontOfSize:12];
                
                cell.accessoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                
                [(UIActivityIndicatorView *)cell.accessoryView startAnimating];
            }
            else
            {
                MDIOSSettingTextFieldTableViewCell *cell2 = (MDIOSSettingTextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
                
                cell2.textLabel.text = @"Local IP";
                cell2.textField.placeholder = NSLocalizedString(@"192.168.0.10", @"IP placeholder");
                cell = (UITableViewCell *)cell2;
            }
        }
    }
    
    // Configure the cell...
    return cell;
}

- (IBAction)switchValueChanged:(id)sender
{
    UISwitch *aSwitch = (UISwitch *)sender;
    self.showLocalConnection = aSwitch.on;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_BUTTON_SECTION)
    {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if(cell.tag == 0)
        {
            [self loginTapped];
        }
        else
        {
            [self disconnectTapped];
        }

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_BUTTON_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark login/logout stack

- (IBAction)loginTapped
{
    self.tryToConnect = YES;
    [self.tableView.superview endEditing:YES];
    
//    [self.passwordField resignFirstResponder];
//    [self.emailField resignFirstResponder];
//    [self.networkActivityIndicator startAnimating];

    
    
//    self.connectionStateInfoText.text = NSLocalizedString(@"tryToConnectMessage", @"Try to connect message in preference");
//    self.connectionStateInfoText.textColor = [UIColor darkGrayColor];
//    self.connectionStateInfoText.hidden = NO;
//    self.statusImage.hidden = YES;
    
//    
    [[MDDSSManager defaultManager] checkRemoteConnectivityFor:self.currentUsername password:self.currentPassword callback:^(NSDictionary *json, NSError *error)
     {
         if(error == NO && json && [json objectForKey:@"Response"] != [NSNull null] && [[json objectForKey:@"Response"] objectForKey:@"RelayLink"])
         {
             // we have connection
             NSURL *url = [NSURL URLWithString:[[json objectForKey:@"Response"] objectForKey:@"RelayLink"]];
             
             [[MDDSSManager defaultManager] setAndPersistHost:url.host];
             [MDDSSManager defaultManager].useRemoteConnectivity = YES;
             [[MDDSSManager defaultManager] setRemoteConnectivityUsername:self.currentUsername];
             
             NSString *token = [[json objectForKey:@"Response"] objectForKey:@"Token"];
             
             [[MDDSSManager defaultManager] loginApplication:token callBlock:^(NSDictionary *json, NSError *error)
              {
                  if([json objectForKey:@"result"] && [[json objectForKey:@"result"] objectForKey:@"token"])
                  {
                      self.tryToConnect = NO;
                      self.connectionError = NO;

                      [self.tableView reloadData];
                      
                      [[NSNotificationCenter defaultCenter] postNotificationName:kMD_NOTIFICATION_APPTOKEN_DID_CHANGE object:nil];
                  }
              }
              ];
         }
         else
         {
             
             self.tryToConnect = NO;
             self.connectionError = YES;
             [self.tableView reloadData];
         }
     }
     ];
}

- (IBAction)disconnectTapped
{
    [[MDDSSManager defaultManager] setAndPersistHost:@""];
    [MDDSSManager defaultManager].useRemoteConnectivity = NO;
    
    [self.tableView reloadData];
}

#pragma mark - UITextField Stack

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        self.currentUsername = textField.text;
    }
    else if(textField.tag == 2)
    {
        self.currentPassword = textField.text;
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
