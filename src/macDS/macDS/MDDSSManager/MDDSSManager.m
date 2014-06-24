//
//  MDDSSManager.m
//  macDS
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDDSSManager.h"
#import "MDDSSURLConnection.h"

static MDDSSManager *defaultManager;

@interface MDDSSManager ()
@property NSMutableData *connectionData;

@property NSString *currentSessionToken;
@end

@implementation MDDSSManager

+ (MDDSSManager *)defaultManager
{
    if(!defaultManager)
    {
        defaultManager = [[MDDSSManager alloc] init];
    }
    return defaultManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)loginApplication:(NSString *)loginToken
{
    [MDDSSURLConnection jsonConnectionWithPath:@"/json/system/loginApplication" params:[NSDictionary dictionaryWithObject:@"f0e037b369db3b22d03390f1cb8a931c475aca9c1a556f26cde89b03849c334a" forKey:@"loginToken"] completionHandler:^(NSDictionary *json, NSError *error){
        
        if([json objectForKey:@"result"] && [[json objectForKey:@"result"] objectForKey:@"token"])
        {
            self.currentSessionToken = [[json objectForKey:@"result"] objectForKey:@"token"];
            
            [self getStructure];
        }
        
    }];
}

- (void)getStructure
{
    [MDDSSURLConnection jsonConnectionWithPath:@"/json/apartment/getStructure" params:[NSDictionary dictionaryWithObject:self.currentSessionToken forKey:@"token"] completionHandler:^(NSDictionary *json, NSError *error){
        
        NSLog(@"%@", json);
        
        for(NSDictionary *zoneDict in [[[json objectForKey:@"result"] objectForKey:@"apartment"] objectForKey:@"zones"])
        {
            NSLog(@"%@=%@", [zoneDict objectForKey:@"name"], [zoneDict objectForKey:@"id"]);
            
        }
        
        //[self setValueOfDSID:@"303505d7f8000040000217f4" value:@"255"];
        [self zoneGetName:@"4"];
        [self zoneId:@"4" callScene:@"5" groupID:@"2"];
    }];
}

- (void)setValueOfDSID:(NSString *)dsid value:(NSString *)value
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid": dsid, @"value": value };
    [MDDSSURLConnection jsonConnectionWithPath:@"/json/device/setValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
        
        NSLog(@"%@", json);
        
        [self setValueOfDSID:@"303505d7f8000040000217f4" value:@"0"];

    }];
}

- (void)zoneId:(NSString *)zoneId callScene:(NSString *)sceneNumber groupID:(NSString *)groupID
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"id":zoneId, @"force":@"true",@"groupNumber":@"1",@"groupID":@"1", @"sceneNumber":sceneNumber  };
    [MDDSSURLConnection jsonConnectionWithPath:@"/json/zone/callScene" params:params completionHandler:^(NSDictionary *json, NSError *error){
        
        NSLog(@"%@", json);

        
    }];
}

- (void)zoneGetName:(NSString *)zoneId
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"id":zoneId};
    [MDDSSURLConnection jsonConnectionWithPath:@"/json/zone/getName" params:params completionHandler:^(NSDictionary *json, NSError *error){
        
        NSLog(@"%@", json);
        
        
    }];
}



@end
