//
//  AppDelegate.m
//  DSMenu-iOS
//
//  Created by Jonas Schnelli on 17.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDIOSAppDelegate.h"
#import "MDDSSManager.h"
#import "MDDSSConsumptionManager.h"
#import "BWQuincyManager.h"

@interface MDIOSAppDelegate ()

@end

@implementation MDIOSAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[BWQuincyManager sharedQuincyManager] setSubmissionURL:@"https://dsmenu.include7.ch/quincy/crash_v300.php"];
    [[BWQuincyManager sharedQuincyManager] startManager];
    
    
    NSString *name = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"https://dsmenu.include7.ch/quincy/ping.php?ping=1&n=%@&v=3&t=s", name ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
    }];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc]
                                        initWithSuiteName:@"group.com.include7.DSMenu"];
    
    
    [MDDSSManager defaultManager].currentUserDefaults = mySharedDefaults;
    [[MDDSSManager defaultManager] loadDefaults];
    
    [MDDSSManager defaultManager].appName = @"DSMenuiOS";
    [MDDSSManager defaultManager].appUUID = @"e4634770-11a3-412f-9946-91911c2a4d25";
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginError) name:kDS_DSS_AUTH_ERROR object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStructure) name:kDS_SHOULD_TRY_TO_RELOAD_STRUCTURE object:nil];
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPollingConsumptionData) name:kDS_SHOULD_START_POLLING_CONSUMPTION_DATA object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPollingConsumptionData) name:kDS_SHOULD_STOP_POLLING_CONSUMPTION_DATA object:nil];
    
    
    return YES;
}

- (void)loginError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"errorConnecting", @"")message:NSLocalizedString(@"applicationTokenRequested", @"") delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    // only show login error once
    [MDDSSManager defaultManager].suppressAuthError = YES;
}

- (void)loadStructure
{
    if(![MDDSSManager defaultManager].canConnect)
    {
        return;
    }
    [[MDDSSManager defaultManager] getStructureWithCustomSceneNames:^(NSDictionary *json, NSError *error){
        self.structure = json;
        [[NSNotificationCenter defaultCenter] postNotificationName:kDS_STRUCTURE_DID_CHANGE object:self.structure];
    }];
}

- (void)startPollingConsumptionData
{
    if(![MDDSSManager defaultManager].canConnect)
    {
        return;
    }
    [MDDSSConsumptionManager defaultManager].callbackLatest = ^(NSArray *json, NSError *error){
        
        NSMutableAttributedString* str =[[NSMutableAttributedString alloc] initWithString:@""];
        
        self.consumptionData = [NSMutableArray arrayWithCapacity:10];
        
        int cnt=0;
        int total = 0;
        for(NSDictionary *dSM in json)
        {
            NSString *name = [[MDDSSConsumptionManager defaultManager] dSMNameFromID:[dSM objectForKey:@"dsid"]];
            
            NSString *dsid = [dSM objectForKey:@"dsid"];
            
            NSString *dSUID = [dSM objectForKey:@"dSUID"];
            if(dSUID && dSUID.length > 4)
            {
                name = [[MDDSSConsumptionManager defaultManager] dSMNameFromID:dSUID];
                dsid = [dSM objectForKey:@"dSUID"];
            }
            
            NSString *value = [[dSM objectForKey:@"value"] stringValue];
            total += [[dSM objectForKey:@"value"] intValue];
            [str appendAttributedString:[[NSMutableAttributedString alloc] initWithString:value]];
            if(cnt+1 < json.count)
            {
                [str appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
            }
            cnt++;
            
            if(!name)
            {
                name = @"undef";
            }
            if(!value)
            {
                value = @"";
            }
            [self.consumptionData addObject:@{@"name": name, @"value": value, @"dsid" : dsid}];
        }
        
        [self.consumptionData sortUsingComparator:^ NSComparisonResult(NSDictionary *d1, NSDictionary *d2){
            return [[d1 objectForKey:@"name"] compare:[d2 objectForKey:@"name"]];
        }];
        
        [self.consumptionData insertObject:@{@"name": @"all", @"value": [NSString stringWithFormat:@"%d", total], @"dsid" : @"all"}
                                   atIndex:0
         ];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDS_CONSUMPTION_DID_CHANGE object:self.consumptionData];
    };
    
    [[MDDSSConsumptionManager defaultManager] startPollingHistory:10];
    [[MDDSSConsumptionManager defaultManager] startPollingLatest:2];
}

- (void)stopPollingConsumptionData
{
    [[MDDSSConsumptionManager defaultManager] stopPollingHistory];
    [[MDDSSConsumptionManager defaultManager] stopPollingLatest];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [MDDSSManager defaultManager].suppressAuthError = NO;
    [self loadStructure];
    
    NSString *name = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"https://dsmenu.include7.ch/quincy/ping.php?ping=1&n=%@&v=3&t=o", name ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
