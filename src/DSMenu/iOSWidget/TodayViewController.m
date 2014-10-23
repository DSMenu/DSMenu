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
    if(self.hasDSSManagerAvailable == NO)
    {
        [self initDSSManager];
    }
    
    CGPoint currentPosition = CGPointMake(0, 5);
    CGSize widgetViewSize = CGSizeMake(100, 44);
    CGSize widgetSpace = CGSizeMake(5, 5);
    NSArray *favs = [MDIOSWidgetManager defaultManager].allFavoritesUUIDs;
    for(MDIOSWidgetAction *action in favs)
    {
        
        if(currentPosition.x+widgetViewSize.width+widgetSpace.width > self.view.bounds.size.width)
        {
            currentPosition.x = 0;
            currentPosition.y += widgetViewSize.height+widgetSpace.height;
        }
        
        MDIOSFavorite *favorite = [[MDIOSFavoritesManager defaultManager] favoriteForUUID:action.favoriteUUID];
        MDIOSWidgetView *wview = [[MDIOSWidgetView alloc] initWithFrame:CGRectMake(currentPosition.x,currentPosition.y,widgetViewSize.width,widgetViewSize.height) andFavorite:favorite];
        
        [wview addTarget:self action:@selector(widgetActionTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:wview];
        currentPosition.x += widgetViewSize.width+widgetSpace.width;
    }
    
    self.preferredContentSize = CGSizeMake(0, currentPosition.y+widgetViewSize.height+widgetSpace.height);
    
    //self.view.frame = CGRectMake(0,0,320,currentPosition.y+widgetViewSize.height+widgetSpace.height);
    completionHandler(NCUpdateResultNewData);
}

- (void)widgetActionTapped:(id)sender
{
    MDIOSWidgetView *wview = (MDIOSWidgetView *)sender;
    
    [wview.loadingIndicator startAnimating];
    if(wview.favorite.favoriteType == MDIOSFavoriteTypeZonePreset)
    {
        [[MDDSSManager defaultManager] callScene:wview.favorite.scene zoneId:wview.favorite.zone groupID:wview.favorite.group callback:^(NSDictionary *json, NSError *error)
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
