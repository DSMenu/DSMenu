//
//  MDDSSManager.m
//  macDS
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDDSSManager.h"
#import "MDDSSURLConnection.h"

#define kMDDSSMANAGER_APPLICATION_TOKEN_UD_KEY @"MDDSSManagerApplicationToken"
#define kMDDSSMANAGER_APPLICATION_TOKEN_MIN_LENGTH 3

static MDDSSManager *defaultManager;

@interface MDDSSManager ()
@property NSString *applicationToken;
@property NSString *currentSessionToken;
@property (readonly) NSString *hostWithPort;

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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.applicationToken = [defaults objectForKey:kMDDSSMANAGER_APPLICATION_TOKEN_UD_KEY];
        self.currentSessionToken = @""; // use a empty string as not-logged-in indicator
        self.port = @"8080";
        self.host = @"192.168.0.1";
    }
    return self;
}

- (NSString *)hostWithPort
{
    return [self.host stringByAppendingFormat:@":%@", self.port];
}

- (BOOL)hasApplicationToken
{
    if(self.applicationToken == nil || self.applicationToken.length < kMDDSSMANAGER_APPLICATION_TOKEN_MIN_LENGTH)
    {
        return NO;
    }
    return YES;
}

- (void)persistApplicationToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.applicationToken forKey:kMDDSSMANAGER_APPLICATION_TOKEN_UD_KEY];
    [defaults synchronize];
}

- (void)handleResult:(NSDictionary *)json
{
    if([json objectForKey:@"ok"] == NULL)
    {
        //error, try to login
    }
}

- (void)jsonCall:(NSString *)path params:(NSDictionary *)params completionHandler:(void (^)(NSDictionary*, NSError*))handler
{
    [MDDSSURLConnection jsonConnectionToHostWithPort:self.hostWithPort path:path params:params completionHandler:^(NSDictionary *json, NSError *error){
        
        NSLog(@"json: %@", [json objectForKey:@"ok"]);
        if([[json objectForKey:@"ok"] intValue] == 0)
        {
            
            
            if([[json objectForKey:@"message"] isEqualToString:@"Application-Authentication failed"])
            {
                //ERROR TODO
                NSLog(@"ERROR, can't login");
                NSError *error = [NSError errorWithDomain:@"" code:1 userInfo:nil]; // TODO
                handler(nil, error);
            }
            
            //error, try to login
            [self loginApplication:self.applicationToken callBlock:^(NSDictionary *json, NSError *error){
                    
                [MDDSSURLConnection jsonConnectionToHostWithPort:self.hostWithPort path:path params:params completionHandler:^(NSDictionary *json, NSError *error){
                    // try again
                    handler(json, error);
                }];
                
            }];
        }
        else
        {
            // valid result
            handler(json, error);
        }
    }];
}

- (void)requestApplicationToken:(void (^)(NSDictionary*, NSError*))callback
{
    [self jsonCall:@"/json/system/requestApplicationToken" params:[NSDictionary dictionaryWithObject:self.appName forKey:@"applicationName"] completionHandler:^(NSDictionary *json, NSError *error){
        
        if([json objectForKey:@"result"] && [[json objectForKey:@"result"] objectForKey:@"applicationToken"])
        {
            self.applicationToken = [[json objectForKey:@"result"] objectForKey:@"applicationToken"];
            [self persistApplicationToken];
            
            callback(json, error);
        }
        
    }];
}

- (void)loginApplication:(NSString *)loginToken callBlock:(void (^)(NSDictionary*, NSError*))handler
{
    [self jsonCall:@"/json/system/loginApplication" params:[NSDictionary dictionaryWithObject:self.applicationToken forKey:@"loginToken"] completionHandler:^(NSDictionary *json, NSError *error){
        
        if([json objectForKey:@"result"] && [[json objectForKey:@"result"] objectForKey:@"token"])
        {
            self.currentSessionToken = [[json objectForKey:@"result"] objectForKey:@"token"];
            handler(json, error);
        }
        
    }];
}

- (void)getStructure:(void (^)(NSDictionary*, NSError*))callback
{

    [self jsonCall:@"/json/apartment/getStructure" params:[NSDictionary dictionaryWithObject:self.currentSessionToken forKey:@"token"] completionHandler:^(NSDictionary *json, NSError *error){
        

        callback(json, error);
  
        //[self setValueOfDSID:@"303505d7f8000040000217f4" value:@"255"];
//        [self zoneGetName:@"4"];
//        [self zoneId:@"4" callScene:@"5" groupID:@"2"];
    }];
}

- (void)setValueOfDSID:(NSString *)dsid value:(NSString *)value
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid": dsid, @"value": value };
    [self jsonCall:@"/json/device/setValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
        
        NSLog(@"%@", json);
        
        [self setValueOfDSID:@"303505d7f8000040000217f4" value:@"0"];

    }];
}

- (void)callScene:(NSString *)sceneNumber zoneId:(NSString *)zoneId groupID:(NSString *)groupID callback:(void (^)(NSDictionary*, NSError*))callback
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"id":zoneId, @"force":@"true",@"groupNumber":@"1",@"groupID":@"1", @"sceneNumber":sceneNumber  };
    [self jsonCall:@"/json/zone/callScene" params:params completionHandler:^(NSDictionary *json, NSError *error){
        callback(json, error);
    }];
}

- (void)callScene:(NSString *)sceneNumber deviceId:(NSString *)deviceId callback:(void (^)(NSDictionary*, NSError*))callback
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":deviceId, @"sceneNumber":sceneNumber  };
    [self jsonCall:@"/json/device/callScene" params:params completionHandler:^(NSDictionary *json, NSError *error){
        callback(json, error);
    }];
}

- (void)zoneGetName:(NSString *)zoneId
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"id":zoneId};
    [self jsonCall:@"/json/zone/getName" params:params completionHandler:^(NSDictionary *json, NSError *error){
        
        NSLog(@"%@", json);
        
        
    }];
}



@end
