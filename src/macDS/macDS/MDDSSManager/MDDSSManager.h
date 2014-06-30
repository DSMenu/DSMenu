//
//  MDDSSManager.h
//  macDS
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDDSSManager : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property NSString *appName;
@property NSString *host;
@property NSString *port;
@property (readonly) BOOL hasApplicationToken;

+ (MDDSSManager *)defaultManager;
- (void)getStructure:(void (^)(NSDictionary*, NSError*))callback;
- (void)requestApplicationToken:(void (^)(NSDictionary*, NSError*))callback;
- (void)callScene:(NSString *)sceneNumber zoneId:(NSString *)zoneId groupID:(NSString *)groupID callback:(void (^)(NSDictionary*, NSError*))callback;
- (void)callScene:(NSString *)sceneNumber deviceId:(NSString *)deviceId callback:(void (^)(NSDictionary*, NSError*))callback;

@end
