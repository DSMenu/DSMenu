//
//  MDIOSDevicesViewController.m
//  DSMenu
//
//  Created by Jonas Schnelli on 29.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSDevicesViewController.h"
#import "MDDSSManager.h"
#import "UIAlertView+DSMenuiOS.h"

@interface MDIOSDevicesViewController ()
@property NSString *lastKnowScene;
@end

@implementation MDIOSDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.deviceValueSlider.maximumValue = 255.0;
    self.deviceValueSlider.minimumValue = 0.0;
    self.deviceValueSlider.continuous = NO;
    self.deviceValueSlider.value = 0.0;
    
    self.currentValue.text = @"";
    self.currentScene.text = NSLocalizedString(@"loadingScene", @"");
    
    self.title = [self.device objectForKey:@"name"];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    
    self.isLoading = NO;
    // Do any additional setup after loading the view.
}

- (void)setIsLoading:(BOOL)status
{
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)self.navigationItem.rightBarButtonItem.customView;
    (status) ? [activityIndicator startAnimating] : [activityIndicator stopAnimating];
}

- (BOOL)isLoading
{
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)self.navigationItem.rightBarButtonItem.customView;
    return activityIndicator.isAnimating;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isLoading = YES;
    self.deviceValueSlider.alpha = 0.5;
    self.deviceValueSlider.enabled = NO;
    
    [[MDDSSManager defaultManager] getValueOfDSID:[self.device objectForKey:@"id"] callback:^(int value, NSError *error)
    {
        self.deviceValueSlider.alpha = 1.0;
        self.deviceValueSlider.enabled = YES;
        self.deviceValueSlider.value = value;
        
        self.currentValue.text = [NSString stringWithFormat:@"%.0f%%", round(100.0/255.0*value)];
        if(value == 255)
        {
            self.deviceSwitch.on = YES;
        }
        else
        {
            self.deviceSwitch.on = NO;
        }
        
        [[MDDSSManager defaultManager] lastCalledSceneInZoneId:[self.device objectForKey:@"zoneID"] groupID:[MDDSHelper mainGroupForDevice:self.device]  callback:^(NSDictionary *json, NSError *error) {
            self.isLoading = NO;
            if(json && [json objectForKey:@"result"])
            {
                NSString *key = [NSString stringWithFormat:@"group%@scene%@", [MDDSHelper mainGroupForDevice:self.device], [[json objectForKey:@"result"] objectForKey:@"scene"]];
                
                self.lastKnowScene = [[json objectForKey:@"result"] objectForKey:@"scene"];
                self.currentScene.text = NSLocalizedString(key, @"");
            }
            else
            {
                self.currentScene.text = NSLocalizedString(@"unknownScene", @"");
            }
        }];
    }];
}

- (IBAction)changeValue:(id)sender
{
    if(sender == self.deviceValueSlider)
    {
        self.isLoading = YES;
        if(self.deviceValueSlider.value == 255.0f)
        {
            self.deviceSwitch.on = YES;
        }
        else
        {
            self.deviceSwitch.on = NO;
        }
        
        self.currentValue.text = [NSString stringWithFormat:@"%.0f%%", round(100.0/255.0*self.deviceValueSlider.value)];
        
        [[MDDSSManager defaultManager] setValueOfDSID:[self.device objectForKey:@"id"] value:[NSString stringWithFormat:@"%.0f", round(self.deviceValueSlider.value)] callback:^(NSDictionary *json, NSError *error) {
            self.isLoading = NO;
        }];
    }
    else if(sender == self.deviceSwitch)
    {
        self.isLoading = YES;
        NSString *value = self.deviceSwitch.on ? @"255" : @"0";
        self.deviceValueSlider.value = [value floatValue];
        self.currentValue.text = [NSString stringWithFormat:@"%.0f%%", round(100.0/255.0*[value floatValue])];
        
        [[MDDSSManager defaultManager] setValueOfDSID:[self.device objectForKey:@"id"] value:value callback:^(NSDictionary *json, NSError *error) {
            self.isLoading = NO;
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 2)
    {
        return 2;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2 && indexPath.row == 1)
    {
        if(self.lastKnowScene)
        {
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:nil message:NSLocalizedString(@"AreYouSurePrompt", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"cancelButton", @"Alert cancel Button") otherButtonTitles:NSLocalizedString(@"yesButton", @"Alert YES Button"), nil];
            [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if(buttonIndex == 1)
                {
                    self.isLoading = YES;
                    [[MDDSSManager defaultManager] saveSceneForDevice:[self.device objectForKey:@"id"] scene:self.lastKnowScene callback:^(NSDictionary *json, NSError *error) {
                        self.isLoading = NO;
                    }];
                }
            }];
            
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return NSLocalizedString(@"changeValueSection", @"");
    }
    else if(section == 1)
    {
        return NSLocalizedString(@"switchSection", @"");
    }
    else if(section == 2)
    {
        return NSLocalizedString(@"setSceneSection", @"");
    }
    return nil;
}

@end
