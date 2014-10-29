//
//  TodayViewController.m
//  iOSWidget
//
//  Created by Jonas Schnelli on 20.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "MDIOSWidgetManager.h"
#import "MDIOSFavoritesManager.h"
#import "MDIOSWidgetView.h"
#import "Constantes.h"

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
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc]
                                        initWithSuiteName:@"group.com.include7.DSMenu"];
    
    if(self.hasDSSManagerAvailable == NO)
    {
        [self initDSSManager];
    }
    
    // hack for running around the UserDefaults sync bug in iOS 8
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kDSMENU_APP_GROUP_IDENTIFIER];
    NSURL *containerURLFile = [containerURL URLByAppendingPathComponent:kDSMENU_SECURITY_NAME_FOR_USERDEFAULTS];
    NSDictionary *userDefaults = [NSDictionary dictionaryWithContentsOfURL:containerURLFile];
    for(NSString *aKey in userDefaults.allKeys)
    {
        [[MDDSSManager defaultManager].currentUserDefaults setObject:[userDefaults objectForKey:aKey] forKey:aKey];
    }
    
    containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kDSMENU_APP_GROUP_IDENTIFIER];
    containerURLFile = [containerURL URLByAppendingPathComponent:kDSMENU_SECURITY_NAME_FOR_WIDGET_ACTIONS];
    NSData *data = [NSData dataWithContentsOfURL:containerURLFile];
    NSMutableDictionary *widgetActions = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    
    containerURLFile = [containerURL URLByAppendingPathComponent:kDSMENU_SECURITY_NAME_FOR_FAVORITES];
    data = [NSData dataWithContentsOfURL:containerURLFile];
    NSArray *favorites = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    
    NSDictionary *json = [MDDSSManager defaultManager].lastLoadesStructure;
    
    CGPoint currentPosition = CGPointMake(0, 5);
    CGSize widgetViewSize = CGSizeMake(100, 44);
    CGSize widgetSpace = CGSizeMake(5, 5);
    NSArray *favs = [MDIOSWidgetManager defaultManager].allFavoritesUUIDs;
    for(MDIOSWidgetAction *action in [widgetActions objectForKey:@"favs"])
    {
        
        if(currentPosition.x+widgetViewSize.width+widgetSpace.width > self.view.bounds.size.width)
        {
            currentPosition.x = 0;
            currentPosition.y += widgetViewSize.height+widgetSpace.height;
        }
        
        MDIOSFavorite *favorite = nil;
        
        for(MDIOSFavorite *aFavorite in favorites)
        {
            if([aFavorite.UUID isEqualToString:action.favoriteUUID])
            {
                favorite = aFavorite;
            }
        }
        
        if(favorite.favoriteType == MDIOSFavoriteTypeZone)
        {
            favorite.group = @"1";
            
            MDIOSWidgetView *wview = [[MDIOSWidgetView alloc] initWithFrame:CGRectMake(currentPosition.x,currentPosition.y,widgetViewSize.width,widgetViewSize.height) andFavorite:favorite];
            [wview addTarget:self action:@selector(widgetActionTapped:) forControlEvents:UIControlEventTouchUpInside];
            wview.tag = 1;
            [self.view addSubview:wview];
            currentPosition.x += widgetViewSize.width+widgetSpace.width;
            
            if(currentPosition.x+widgetViewSize.width+widgetSpace.width > self.view.bounds.size.width)
            {
                currentPosition.x = 0;
                currentPosition.y += widgetViewSize.height+widgetSpace.height;
            }
            
            favorite.group = @"2";
            
            wview = [[MDIOSWidgetView alloc] initWithFrame:CGRectMake(currentPosition.x,currentPosition.y,widgetViewSize.width,widgetViewSize.height) andFavorite:favorite];
            [wview addTarget:self action:@selector(widgetActionTapped:) forControlEvents:UIControlEventTouchUpInside];
            wview.tag = 2;
            [self.view addSubview:wview];
            currentPosition.x += widgetViewSize.width+widgetSpace.width;
            
        }
        else
        {
            MDIOSWidgetView *wview = [[MDIOSWidgetView alloc] initWithFrame:CGRectMake(currentPosition.x,currentPosition.y,widgetViewSize.width,widgetViewSize.height) andFavorite:favorite];
            [wview addTarget:self action:@selector(widgetActionTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.view addSubview:wview];
            currentPosition.x += widgetViewSize.width+widgetSpace.width;
        }
    }
    
    self.noFavoritesLabel.hidden = YES;
    if(!favs || favs.count == 0)
    {
        self.noFavoritesLabel.hidden = NO;
    }
    
    self.preferredContentSize = CGSizeMake(0, currentPosition.y+widgetViewSize.height+widgetSpace.height);
    completionHandler(NCUpdateResultNewData);
}

- (void)widgetActionTapped:(id)sender
{
    MDIOSWidgetView *wview = (MDIOSWidgetView *)sender;
    
    [wview.loadingIndicator startAnimating];
    
    NSString *scene = wview.favorite.scene;
    NSString *group = wview.favorite.group;
    
    if(wview.favorite.favoriteType == MDIOSFavoriteTypeZone)
    {
        group = [NSString stringWithFormat:@"%ld",wview.tag];
        
        [[MDDSSManager defaultManager] lastCalledSceneInZoneId:wview.favorite.zone groupID:group callback:^(NSDictionary *json, NSError *error)
         {
             if(!error && [json objectForKey:@"result"])
             {
                 NSString *cScene = [[json objectForKey:@"result"] objectForKey:@"scene"];
                 int desiredScene = [MDDSHelper nextScene:[cScene intValue] group:[group intValue]];
                 
                 NSString *sceneString = [NSString stringWithFormat:@"%d", desiredScene];
                 [[MDDSSManager defaultManager] callScene:sceneString zoneId:wview.favorite.zone groupID:group callback:^(NSDictionary *json, NSError *error)
                  {
                      [wview.loadingIndicator stopAnimating];
                  }];
             }
         }];
    }
    else
    {
    
        [[MDDSSManager defaultManager] callScene:scene zoneId:wview.favorite.zone groupID:group callback:^(NSDictionary *json, NSError *error)
         {
             [wview.loadingIndicator stopAnimating];
         }];
    }
}

- (void)initDSSManager
{
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc]
                                        initWithSuiteName:@"group.com.include7.DSMenu"];
    
    
    NSLog(@"NSUserDefaults dump: %@", [mySharedDefaults dictionaryRepresentation]);
    
    [MDDSSManager defaultManager].currentUserDefaults = mySharedDefaults;
    [[MDDSSManager defaultManager] loadDefaults];
    
    [MDDSSManager defaultManager].appName = @"DSMenuiOS";
    [MDDSSManager defaultManager].appUUID = @"e4634770-11a3-412f-9946-91911c2a4d25";
    
    
    self.hasDSSManagerAvailable = YES;
    
    
    NSLog(@"%@", [MDDSSManager defaultManager].host);
    [[MDDSSManager defaultManager] getVersion:^(NSDictionary *json, NSError *error)
    {
        NSLog(@"%@", json);
    }];
}

@end
