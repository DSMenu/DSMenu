//
//  MDIOSScenePresetTableViewCell.h
//  DSMenu
//
//  Created by Jonas Schnelli on 19.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDIOSScenePresetTableViewCell : UITableViewCell

@property (assign) BOOL isFavorized;
@property (assign) BOOL isLoading;
@property (strong) NSString *zone;
@property (strong) NSString *group;
@property (strong) NSString *scene;
@property (strong) UIButton *favorizeButton;
- (void)checkFavoriteState;
@end
