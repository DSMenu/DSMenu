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

#define kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_SECTION 2
#define kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_BUTTON_SECTION 3
#define kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION 0
#define kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_BUTTON_SECTION 1

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
    else
    {
        if([MDDSSManager defaultManager].host && [MDDSSManager defaultManager].host.length > 0)
        {
            self.currentIPAddressOrHostname = [MDDSSManager defaultManager].host;
        }
    }
    
    [self startBonjourSearch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - mDNS / Bonjour Stack

- (void)startBonjourSearch
{
    self.searchingMDNS = YES;
    NSTimer *timer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(searchEnd) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    [self.netServiceBrowser searchForServicesOfType:@"_http._tcp." inDomain:@"local"];
}
- (void)searchEnd
{
    if(self.searchingMDNS)
    {
        self.searchingMDNS = NO;
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.mDNSServices.count inSection:kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    [self.mDNSServices addObject:aNetService];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    DDLogVerbose(@"%@ %@", [aNetService.name stringByAppendingString:@".local"], [MDDSSManager defaultManager].host);

    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    DDLogDebug(@"%@ %@", aNetService.name, [NSNumber numberWithLong:[aNetService port]]);
    DDLogDebug(@"%@", [[NSString alloc] initWithData:aNetService.TXTRecordData encoding:NSUTF8StringEncoding]);
}

-(void)netServiceDidResolveAddress:(NSNetService *)sender
{
    DDLogDebug( ([NSString stringWithFormat:@"Service resolved. Host name: %@ Port number: %@", [sender hostName], [NSNumber numberWithLong:[sender port]]]), @"" );
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_SECTION)
    {
        return NSLocalizedString(@"remoteConnectivityTab", @"");
    }
    else if(section == kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION)
    {
        return NSLocalizedString(@"localConnectionTab", @"");
    }
    else
    {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_BUTTON_SECTION)
    {
        return @"Connect Over The Internet By Using The Remote Connectivity (mein.digitalSTROM) App On Your dSS";
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION && self.searchingMDNS && indexPath.row == self.mDNSServices.count)
    {
        return 33.0;
    }
    return self.tableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION)
    {
        return 52.0;
    }
    else if(section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_SECTION)
    {
        return 40.0;
    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_SECTION || section == kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION)
    {
        return 1;
    }
    else if(section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_BUTTON_SECTION)
    {
        return 60;
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
        return 1+self.mDNSServices.count+self.searchingMDNS;
    }
    else if(section == kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_BUTTON_SECTION)
    {
        return 0;
    }
    
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.imageView.image = nil;
    if(indexPath.section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_SECTION)
    {
        MDIOSSettingTextFieldTableViewCell *cell2 = (MDIOSSettingTextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
        
        
        NSString *usernameLabel = NSLocalizedString(@"usernameLabel", @"Usernamel label");
        NSString *passwordLabel = NSLocalizedString(@"passwordLabel", @"Password label");
        
        cell2.textLabel.text = usernameLabel;
        CGRect sizeUsername = [cell2.textLabel textRectForBounds:CGRectMake(0,0,1000,30) limitedToNumberOfLines:1];
        
        cell2.textLabel.text = passwordLabel;
        CGRect sizePassword = [cell2.textLabel textRectForBounds:CGRectMake(0,0,1000,30) limitedToNumberOfLines:1];
        
        if(sizePassword.size.width > sizeUsername.size.width)
        {
            cell2.constraintsHelperLabel.text = passwordLabel;
        }
        else
        {
            cell2.constraintsHelperLabel.text = usernameLabel;
        }
        
        
        if(indexPath.row == 0)
        {
            cell2.textLabel.text = usernameLabel;
            cell2.textField.placeholder = NSLocalizedString(@"usernamePlaceholder", @"username placeholder");
            cell2.textField.tag = 1;
            cell2.textField.keyboardType = UIKeyboardTypeEmailAddress;
            cell2.textField.secureTextEntry = NO;
            cell2.accessoryView = nil;
        
            cell2.textField.text = self.currentUsername;
            
            if(self.currentUsername)
            {
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
            cell2.accessoryView = nil;
            cell2.textLabel.text = passwordLabel;
            cell2.textField.text = self.currentPassword;
            cell2.textField.placeholder = NSLocalizedString(@"passwordPlaceholder", @"password placeholder");
            cell2.textField.tag = 2;
            cell2.textField.secureTextEntry = YES;
            cell2.textField.keyboardType =  UIKeyboardTypeDefault;
            
            self.passwordTextField = cell2.textField;
        }

        cell = (UITableViewCell *)cell2;
    }
    else if(indexPath.section == kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_BUTTON_SECTION)
    {
        cell.textLabel.text = NSLocalizedString(@"loginButton", @"login button");
        cell.accessoryView = nil;
        cell.textLabel.textColor = BLUE_LINK_COLOR;
        cell.tag = 0;
        
        if([MDDSSManager defaultManager].useRemoteConnectivity)
        {
            cell.textLabel.text = NSLocalizedString(@"disconnectButton", @"disconnect button");
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
        if(indexPath.row < self.mDNSServices.count)
        {
            
            NSNetService *netService = [self.mDNSServices objectAtIndex:indexPath.row];
            cell.textLabel.text = netService.name;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = [UIImage imageNamed:@"dss.png"];
            
            if([[netService.name stringByAppendingString:@".local"] isEqualToString:[MDDSSManager defaultManager].host])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            if(self.connectionErrorLocal && [self.currentIPAddressOrHostname isEqualToString:[cell.textLabel.text stringByAppendingString:@".local"]])
            {
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert.png"]];
            }
        }
        else
        {
            if(self.searchingMDNS && indexPath.row == self.mDNSServices.count)
            {
                cell.textLabel.text = NSLocalizedString(@"searchingBonjour", @"searching mDNS indicator text");
                cell.textLabel.font = [UIFont systemFontOfSize:12];
                
                cell.accessoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                
                [(UIActivityIndicatorView *)cell.accessoryView startAnimating];
            }
            else
            {
                MDIOSSettingTextFieldTableViewCell *cell2 = (MDIOSSettingTextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
                
                cell2.textLabel.text = NSLocalizedString(@"preferenceMainAddressLabel", @"");
                cell2.textField.placeholder = NSLocalizedString(@"192.168.0.10", @"IP placeholder");
                cell2.textField.tag = 3;
                cell2.textField.secureTextEntry = NO;
                cell2.textField.keyboardType = UIKeyboardTypeDefault;
                cell2.textField.text = self.currentIPAddressOrHostname;
                cell2.constraintsHelperLabel.text = NSLocalizedString(@"preferenceMainAddressLabel", @"");
                cell2.accessoryView = nil;
                
                if(self.connectionErrorLocal && [self.currentIPAddressOrHostname isEqualToString:cell2.textField.text])
                {
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert.png"]];
                }
                
                cell = (UITableViewCell *)cell2;
            }
        }
    }
    else if(indexPath.section == kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_BUTTON_SECTION)
    {
        cell.textLabel.text = NSLocalizedString(@"loginButton", @"login button");
        cell.accessoryView = nil;
        cell.textLabel.textColor = BLUE_LINK_COLOR;
        cell.tag = 100;
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        if(self.tryToConnectLocal) {
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            [activityIndicator startAnimating];
            cell.accessoryView = activityIndicator;
        }
    }
    return cell;
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
    else if(indexPath.section == kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_SECTION)
    {
        if(indexPath.row < self.mDNSServices.count)
        {
            NSNetService *netService = [self.mDNSServices objectAtIndex:indexPath.row];
            
            self.currentIPAddressOrHostname = [netService.name stringByAppendingString:@".local"];
            [self connectLocal];        
        }
    }
    else if(indexPath.section == kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_BUTTON_SECTION)
    {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if(cell.tag == 100)
        {
            [self connectLocal];
        }
        else
        {
            
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kMDIOS_SETTINGS_CONNECTION_LOCAL_CONNECTION_BUTTON_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - login/logout/etc. stack

- (IBAction)loginTapped
{
    self.tryToConnect = YES;
    [self.tableView.superview endEditing:YES];

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
    else if(textField.tag == 3)
    {
        self.currentIPAddressOrHostname = textField.text;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if(textField.tag == 2)
    {
        [self loginTapped];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kMDIOS_SETTINGS_CONNECTION_REMOTE_CONNECTIVITY_BUTTON_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if(textField.tag == 3)
    {
        self.currentIPAddressOrHostname = textField.text;
        [self connectLocal];
    }
    
    return YES;
}

#pragma mark - local check

- (void)connectLocal
{
    self.tryToConnectLocal = YES;
    self.connectionErrorLocal = NO;
    
    [[MDDSSManager defaultManager] checkHost:self.currentIPAddressOrHostname callback:^(BOOL status)
     {
         
         self.tryToConnectLocal = NO;
         if(status)
         {
             
             [[MDDSSManager defaultManager] setAndPersistHost:self.currentIPAddressOrHostname];
             [MDDSSManager defaultManager].useIPAddress = NO;
             [MDDSSManager defaultManager].useRemoteConnectivity = NO;
             
             if([MDDSSManager defaultManager].applicationToken == nil || [MDDSSManager defaultManager].applicationToken.length <= 0)
             {
                 [[MDDSSManager defaultManager] requestApplicationToken:^(NSDictionary *json, NSError *error)
                  {
                      [[NSNotificationCenter defaultCenter] postNotificationName:kMD_NOTIFICATION_APPTOKEN_DID_CHANGE object:nil];
                  }];
             }
             else
             {
                 [[MDDSSManager defaultManager] loginApplication:[MDDSSManager defaultManager].applicationToken callBlock:^(NSDictionary *json, NSError *error)
                  {
                      
                      if([json objectForKey:@"ok"] && [[json objectForKey:@"ok"] intValue] == 1)
                      {
                          if([MDDSSManager defaultManager].useRemoteConnectivity)
                          {
                              [self disconnectTapped];
                          }
                          
                          self.connectionErrorLocal = NO;
                          
                          [[NSNotificationCenter defaultCenter] postNotificationName:kMD_NOTIFICATION_APPTOKEN_DID_CHANGE object:nil];
                          
                          [self searchEnd];
                      }
                      else
                      {
                          [[MDDSSManager defaultManager] requestApplicationToken:^(NSDictionary *json, NSError *error)
                           {
                               [[NSNotificationCenter defaultCenter] postNotificationName:kMD_NOTIFICATION_APPTOKEN_DID_CHANGE object:nil];
                           }];
                      }
                  }];
             }
         }
         else
         {
             self.connectionErrorLocal = YES;
         }
         
         
         [self.tableView reloadData];
     }];
}


@end
