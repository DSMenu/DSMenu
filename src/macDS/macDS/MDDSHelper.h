//
//  MDDSHelper.h
//  macDS
//
//  Created by Jonas Schnelli on 30.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDDSHelper : NSObject
+ (NSImage *)iconForDevice:(NSDictionary *)deviceDictonary;
+ (BOOL)deviceHasLight:(NSDictionary *)deviceDictonary;
+ (BOOL)deviceHasShadow:(NSDictionary *)deviceDictonary;
@end
