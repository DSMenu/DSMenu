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
#define kMDDSSMANAGER_HOST_UD_KEY @"MDDSSManagerHost"
#define kMDDSSMANAGER_USE_IP_ADDRESS_UD_KEY @"MDDSSUseIPAddress"

#define kMDDSSMANAGER_APPLICATION_TOKEN_MIN_LENGTH 3

static MDDSSManager *defaultManager;

@interface MDDSSManager ()
@property NSString *currentSessionToken;
@property (readonly) NSString *hostWithPort;
@property NSDictionary *customSzeneNamesJSONCache;
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
        self.host = @"";
        self.dSSVersionString = nil;
        
        NSString *possibleHost = [[NSUserDefaults standardUserDefaults] objectForKey:kMDDSSMANAGER_HOST_UD_KEY];
        if(possibleHost && [possibleHost isKindOfClass:[NSString class]])
        {
            self.host = possibleHost;
        }
    }
    return self;
}

- (void)setUseIPAddress:(BOOL)useIPAddress
{
    [[NSUserDefaults standardUserDefaults] setBool:useIPAddress forKey:kMDDSSMANAGER_USE_IP_ADDRESS_UD_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)useIPAddress
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kMDDSSMANAGER_USE_IP_ADDRESS_UD_KEY];
}

- (NSString *)hostWithPort
{
    return [self.host stringByAppendingFormat:@":%@", self.port];
}

- (void)setAndPersistHost:(NSString *)host
{
    self.host = host;
    [[NSUserDefaults standardUserDefaults] setObject:self.host forKey:kMDDSSMANAGER_HOST_UD_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMD_NOTIFICATION_HOST_DID_CHANGE object:self.host];
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
        if(error != nil)
        {
            handler(nil, error);
            return;
        }
        DDLogDebug(@"json: %@", [json objectForKey:@"ok"]);
        if([[json objectForKey:@"ok"] intValue] == 0)
        {
            
            
            if([[json objectForKey:@"message"] isEqualToString:@"Application-Authentication failed"])
            {
                //ERROR TODO
                DDLogWarn(@"ERROR, can't login");
                NSError *error = [NSError errorWithDomain:@"" code:MD_ERROR_AUTH_ERROR userInfo:nil]; // TODO
                handler(nil, error);
                return;
            }
            
            //error, try to login
            [self loginApplication:self.applicationToken callBlock:^(NSDictionary *json, NSError *error){
                
                if(error)
                {
                    handler(nil, error);
                    return;
                }
                [self jsonCall:path params:params completionHandler:handler];
            }];
        }
        else
        {
            // valid result
            handler(json, error);
        }
    }];
}

- (void)getVersion:(void (^)(NSDictionary*, NSError*))callback
{
    [self jsonCall:@"/json/system/version" params:nil completionHandler:^(NSDictionary *json, NSError *error){
        if([json objectForKey:@"result"] && [[json objectForKey:@"result"] objectForKey:@"version"])
        {
            self.dSSVersionString = [[json objectForKey:@"result"] objectForKey:@"version"];
        }
       callback(json, error);
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
        }
        
        handler(json, error);
        
    }];
}

- (void)getStructure:(void (^)(NSDictionary*, NSError*))callback
{
    [self jsonCall:@"/json/apartment/getStructure" params:[NSDictionary dictionaryWithObject:self.currentSessionToken forKey:@"token"] completionHandler:^(NSDictionary *json, NSError *error){
        callback(json, error);
    }];
}

- (void)getStructureWithCustomSceneNames:(void (^)(NSDictionary*, NSError*))callback
{
    [self jsonCall:@"/json/apartment/getStructure" params:[NSDictionary dictionaryWithObject:self.currentSessionToken forKey:@"token"] completionHandler:^(NSDictionary *json, NSError *error){
        
        NSDictionary *params = @{ @"token": self.currentSessionToken, @"query": @"/apartment/zones/*(ZoneID,scenes)/groups/*(group)/scenes/*(scene,name)"};
        [self jsonCall:@"/json/property/query" params:params completionHandler:^(NSDictionary *jsonSceneNames, NSError *error){
            self.customSzeneNamesJSONCache = jsonSceneNames;
            callback(json, error);
        }];
    }];
}

- (void)setValueOfDSID:(NSString *)dsid value:(NSString *)value
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid": dsid, @"value": value };
    [self jsonCall:@"/json/device/setValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
        
        DDLogDebug(@"%@", json);


    }];
}

- (void)callScene:(NSString *)sceneNumber zoneId:(NSString *)zoneId groupID:(NSString *)groupID callback:(void (^)(NSDictionary*, NSError*))callback
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"id":zoneId,@"groupID":groupID, @"sceneNumber":sceneNumber  };
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

- (void)turnOnDeviceId:(NSString *)deviceId callback:(void (^)(NSDictionary*, NSError*))callback
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":deviceId};
    [self jsonCall:@"/json/device/turnOn" params:params completionHandler:^(NSDictionary *json, NSError *error){
        callback(json, error);
    }];
}
- (void)turnOffDeviceId:(NSString *)deviceId callback:(void (^)(NSDictionary*, NSError*))callback
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":deviceId};
    [self jsonCall:@"/json/device/turnOff" params:params completionHandler:^(NSDictionary *json, NSError *error){
        callback(json, error);
    }];
}

- (void)zoneGetName:(NSString *)zoneId
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"id":zoneId};
    [self jsonCall:@"/json/zone/getName" params:params completionHandler:^(NSDictionary *json, NSError *error){
        
        DDLogDebug(@"%@", json);
        
        
    }];
}

- (void)getSensorValues:(NSString *)dSID
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":dSID, @"sensorIndex": [NSNumber numberWithInt:1]};
    [self jsonCall:@"/json/device/getSensorValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
        
        DDLogDebug(@"%@", json);
        
        NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":dSID, @"sensorIndex": [NSNumber numberWithInt:2]};
        [self jsonCall:@"/json/device/getSensorValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
            
            DDLogDebug(@"%@", json);
            
            NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":dSID, @"sensorIndex": [NSNumber numberWithInt:3]};
            [self jsonCall:@"/json/device/getSensorValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
                
                DDLogDebug(@"%@", json);
                
                NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":dSID, @"sensorIndex": [NSNumber numberWithInt:4]};
                [self jsonCall:@"/json/device/getSensorValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
                    
                    DDLogDebug(@"%@", json);
                    
                    NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":dSID, @"sensorIndex": [NSNumber numberWithInt:5]};
                    [self jsonCall:@"/json/device/getSensorValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
                        
                        DDLogDebug(@"%@", json);
                        
                        NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":dSID, @"sensorIndex": [NSNumber numberWithInt:6]};
                        [self jsonCall:@"/json/device/getSensorValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
                            
                            DDLogDebug(@"%@", json);
                            
                            
                        }];
                    }];
                }];
            }];
        }];
        
    }];
}

- (void)resetToDefaults
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMDDSSMANAGER_HOST_UD_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMDDSSMANAGER_APPLICATION_TOKEN_UD_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.applicationToken = @"";
    self.currentSessionToken = @"";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMD_NOTIFICATION_HOST_DID_CHANGE object:self.host];
}

- (BOOL)hasCustomSceneNamesForGroup:(int)searchGroup inZone:(int)forZoneId
{
    if(!self.customSzeneNamesJSONCache)
    {
        return NO;
    }
    
    for(NSDictionary *zone in [[self.customSzeneNamesJSONCache objectForKey:@"result"] objectForKey:@"zones"])
    {
        if([[zone objectForKey:@"ZoneID"] intValue] == forZoneId)
        {
            for(NSDictionary *group in [zone objectForKey:@"groups"])
            {
                if([[group objectForKey:@"group"] intValue] == searchGroup)
                {
                    if([[group objectForKey:@"scenes"] count] > 0) {
                        return YES;
                    }
                }
            }
        }
    }
    
    return NO;
}

- (NSArray *)customSceneNamesForGroup:(int)forGroup inZone:(int)forZoneId
{
    //TODO, load scene names in case of empty cache
    if(!self.customSzeneNamesJSONCache)
    {
        return nil;
    }
    
    for(NSDictionary *zone in [[self.customSzeneNamesJSONCache objectForKey:@"result"] objectForKey:@"zones"])
    {
        if([[zone objectForKey:@"ZoneID"] intValue] == forZoneId)
        {
            for(NSDictionary *group in [zone objectForKey:@"groups"])
            {
                if([[group objectForKey:@"group"] intValue] == forGroup)
                {
                    if([[group objectForKey:@"scenes"] count] <= 0)
                    {
                        return nil;
                    }
                    return [group objectForKey:@"scenes"];
                }
            }
        }
    }
    
    return nil;
}

@end
