//
//  MDIOSWidgetAction.h
//  DSMenu
//
//  Created by Jonas Schnelli on 22.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MDIOSWidgetActionType
{
    MDIOSWidgetActionTypeCallScene = 1,
    MDIOSWidgetActionTypeButtonSimulate = 2
} MDIOSWidgetActionType;

@interface MDIOSWidgetAction : NSObject <NSCoding>
@property (strong) NSString *title;
@property (strong) NSString *widgetIconName;
@property (strong) NSString *zone;
@property (strong) NSString *group;
@property (strong) NSString *scene;
@property (assign) MDIOSWidgetActionType actionType;
@end
