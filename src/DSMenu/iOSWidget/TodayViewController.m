//
//  TodayViewController.m
//  iOSWidget
//
//  Created by Jonas Schnelli on 20.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (IBAction)testButtonTapped:(id)sender
{
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc]
                                        initWithSuiteName:@"group.com.include7.DSMenu"];
    
    
    NSLog(@"NSUserDefaults dump: %@", [mySharedDefaults dictionaryRepresentation]);
    
    [MDDSSManager defaultManager].currentUserDefaults = mySharedDefaults;
    [[MDDSSManager defaultManager] loadDefaults];
    
    [MDDSSManager defaultManager].appName = @"DSMenuiOS";
    [MDDSSManager defaultManager].appUUID = @"e4634770-11a3-412f-9946-91911c2a4d25";
    
    
    
    
    NSString *host =[MDDSSManager defaultManager].host;
    
    NSLog(@"%@", [MDDSSManager defaultManager].host);
    [[MDDSSManager defaultManager] getVersion:^(NSDictionary *json, NSError *error)
    {
        NSLog(@"%@", json);
    }];
}

@end
