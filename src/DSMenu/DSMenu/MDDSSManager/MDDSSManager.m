//
//  MDDSSManager.m
//  DSMenu
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDDSSManager.h"
#import "MDDSSURLConnection.h"
#import "Notifications.h"
#import "ErrorCodes.h"
#import "Constantes.h"

#define kMDDSSMANAGER_APPLICATION_TOKEN_UD_KEY @"MDDSSManagerApplicationToken"
#define kMDDSSMANAGER_HOST_UD_KEY @"MDDSSManagerHost"
#define kMDDSSMANAGER_USE_IP_ADDRESS_UD_KEY @"MDDSSUseIPAddress"
#define kMDDSSMANAGER_USE_REMOTE_CONNECTIVITY @"MDDSSUseRemoteConnectivity"
#define kMDDSSMANAGER_REMOTE_CONNECTIVITY_USERNAME @"MDDSSRemoteConnectivityUsername"

#define kMDDSSMANAGER_HISTORY_VALUE_COUNT @"MDDSSManagerHistoryValueCount"
#define kMDDSSMANAGER_LAST_LOADED_CUSTROM_SCENE_NAMES_STRUCTURE @"MDDSSManagerLastLoadedCustomSceneNameStructur"
#define kMDDSSMANAGER_LAST_LOADED_STRUCTURE @"MDDSSManagerLastLoadedStructur"

#define kMDDSSMANAGER_APPLICATION_TOKEN_MIN_LENGTH 3

static MDDSSManager *defaultManager;

@interface MDDSSManager ()
@property NSString *currentSessionToken;
@property (readonly) NSString *hostWithPort;
@end

@implementation MDDSSManager
@synthesize consumptionHistoryValueCount=_consumptionHistoryValueCount;

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
        if(self.applicationToken == nil)
        {
            self.applicationToken = @"";
        }
        self.currentSessionToken = @""; // use a empty string as not-logged-in indicator
        self.port = @"8080";
        self.host = @"";
        self.dSSVersionString = nil;
        self.appUUID = @"8720a278-64d3-49df-ac89-6cb70cafccfd";
        self.useLastCalledSceneCheck = YES;
        self.connectionProblems = NO;
        
        [self loadDefaults];
    }
    return self;
}

- (void)loadDefaults
{
    // must be called after user defaults object has been changed
    NSUserDefaults *defaults = self.userDefaultsProxy;
    self.applicationToken = [defaults objectForKey:kMDDSSMANAGER_APPLICATION_TOKEN_UD_KEY];
    _consumptionHistoryValueCount = [NSNumber numberWithInt:360];
    
    NSNumber *possibleHistoryValueCount = [defaults objectForKey:kMDDSSMANAGER_HISTORY_VALUE_COUNT];
    if(possibleHistoryValueCount && [possibleHistoryValueCount isKindOfClass:[NSNumber class]])
    {
        _consumptionHistoryValueCount = possibleHistoryValueCount;
    }
    
    NSString *possibleHost = [self.userDefaultsProxy objectForKey:kMDDSSMANAGER_HOST_UD_KEY];
    if(possibleHost && [possibleHost isKindOfClass:[NSString class]])
    {
        self.host = possibleHost;
    }
    
    [self loadLastLoadesStructure];
}

- (NSUserDefaults *)userDefaultsProxy
{
    if(self.currentUserDefaults)
    {
        return self.currentUserDefaults;
    }
    return [NSUserDefaults standardUserDefaults];
}

- (void)persist
{
    [self.userDefaultsProxy synchronize];
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kDSMENU_APP_GROUP_IDENTIFIER];
    NSDictionary *dict = [self.userDefaultsProxy dictionaryRepresentation];
    NSURL *containerURLFile = [containerURL URLByAppendingPathComponent:kDSMENU_SECURITY_NAME_FOR_USERDEFAULTS];
    [dict writeToURL:containerURLFile atomically:YES];
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSDictionary *attribs = @{NSFileProtectionKey : NSFileProtectionNone};
    NSError *unprotectError = nil;
    
    BOOL unprotectSuccess = [fm setAttributes:attribs
                                 ofItemAtPath:[containerURL path]
                                        error:&unprotectError];
    if (!unprotectSuccess) {
        NSLog(@"Unable to remove protection from file! %@", unprotectError);
    }
}

- (void)setUseIPAddress:(BOOL)useIPAddress
{
    [self.userDefaultsProxy setBool:useIPAddress forKey:kMDDSSMANAGER_USE_IP_ADDRESS_UD_KEY];
    [self persist];
}

- (BOOL)useIPAddress
{
    return [self.userDefaultsProxy boolForKey:kMDDSSMANAGER_USE_IP_ADDRESS_UD_KEY];
}

- (void)setUseRemoteConnectivity:(BOOL)useRemoteConnectivity
{
    [self.userDefaultsProxy setBool:useRemoteConnectivity forKey:kMDDSSMANAGER_USE_REMOTE_CONNECTIVITY];
    [self persist];
}

- (BOOL)useRemoteConnectivity
{
    return [self.userDefaultsProxy boolForKey:kMDDSSMANAGER_USE_REMOTE_CONNECTIVITY];
}

- (void)setRemoteConnectivityUsername:(NSString *)username
{
    [self.userDefaultsProxy setObject:username forKey:kMDDSSMANAGER_REMOTE_CONNECTIVITY_USERNAME];
    [self persist];
}

- (NSString *)remoteConnectivityUsername
{
    return [self.userDefaultsProxy objectForKey:kMDDSSMANAGER_REMOTE_CONNECTIVITY_USERNAME];
}

- (NSString *)hostWithPort
{
    return [self.host stringByAppendingFormat:@":%@", self.port];
}

- (void)setAndPersistHost:(NSString *)host
{
    self.host = host;
    [self.userDefaultsProxy setObject:self.host forKey:kMDDSSMANAGER_HOST_UD_KEY];
    [self persist];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMD_NOTIFICATION_HOST_DID_CHANGE object:self.host];
}

- (BOOL)canConnect
{
    if(self.host == nil || self.host.length <= 1 )
    {
        return NO;
    }
    return YES;
}

- (void)checkHost:(NSString *)host callback:(void (^)(BOOL))handler
{
    NSString *hostWithPort = [host stringByAppendingFormat:@":8080"];
    
    [MDDSSURLConnection jsonConnectionToHostWithPort:hostWithPort path:@"/json/system/version" params:nil completionHandler:^(NSDictionary *json, NSError *error){
        if([json objectForKey:@"result"] && [[json objectForKey:@"result"] objectForKey:@"version"])
        {
            self.dSSVersionString = [[json objectForKey:@"result"] objectForKey:@"version"];
            handler(YES);
        }
        else {
            handler(NO);
        }
    }];
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
    NSUserDefaults *defaults = self.userDefaultsProxy;
    [defaults setValue:self.applicationToken forKey:kMDDSSMANAGER_APPLICATION_TOKEN_UD_KEY];
    [self persist];
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
    self.connectionProblems = NO;
    [MDDSSURLConnection jsonConnectionToHostWithPort:self.hostWithPort path:path params:params completionHandler:^(NSDictionary *json, NSError *error){
        if(error != nil)
        {
            handler(nil, error);
            return;
        }
#ifdef DDDEBUG
        DDLogDebug(@"json: %@", [json objectForKey:@"ok"]);
#endif
        if([[json objectForKey:@"ok"] intValue] == 0)
        {
            
            
            if([[json objectForKey:@"message"] isEqualToString:@"Application-Authentication failed"])
            {
                //ERROR TODO
                self.connectionProblems = YES;
                #ifdef DDDEBUG
                    DDLogWarn(@"ERROR, can't login");
                #endif
                NSError *error = [NSError errorWithDomain:@"" code:MD_ERROR_AUTH_ERROR userInfo:nil]; // TODO
                handler(nil, error);
                return;
            }
            else
            {
                NSDictionary *userInfo = nil;
                if([json objectForKey:@"message"])
                {
                    userInfo = @{@"message":[json objectForKey:@"message"]};
                }
                NSError *error = [NSError errorWithDomain:@"" code:MD_ERROR_AUTH_ERROR userInfo:userInfo]; //
                handler(nil, error);
            }
//
//            //error, try to login
//            [self loginApplication:self.applicationToken callBlock:^(NSDictionary *json, NSError *error){
//                
//                if(error)
//                {
//                    self.connectionProblems = YES;
//                    handler(nil, error);
//                    
//                    if(!self.suppressAuthError)
//                    {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:kDS_DSS_AUTH_ERROR object:error];
//                    }
//                    return;
//                }
//                [self jsonCall:path params:params completionHandler:handler];
//            }];
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
    if(!loginToken) return;
 
    self.loginInProgress = YES;
    [self jsonCall:@"/json/system/loginApplication" params:[NSDictionary dictionaryWithObject:loginToken forKey:@"loginToken"] completionHandler:^(NSDictionary *json, NSError *error){
        
        self.loginInProgress = NO;
        if([json objectForKey:@"result"] && [[json objectForKey:@"result"] objectForKey:@"token"])
        {
            self.currentSessionToken = [[json objectForKey:@"result"] objectForKey:@"token"];
        }
        
        handler(json, error);
        
    }];
}

- (void)getStructure:(void (^)(NSDictionary*, NSError*))callback
{
    [self precheckWithContinueBlock:^(NSError *error){
        [[NSNotificationCenter defaultCenter] postNotificationName:kDS_START_LOADING_STRUCTURE object:nil];
        [self jsonCall:@"/json/apartment/getStructure" params:[NSDictionary dictionaryWithObject:self.currentSessionToken forKey:@"token"] completionHandler:^(NSDictionary *json, NSError *error){
            
            if(!error)
            {
                self.lastLoadesStructure = json;
                [[self userDefaultsProxy] setObject:self.lastLoadesStructure forKey:kMDDSSMANAGER_LAST_LOADED_STRUCTURE];
                [self persist];
            }
            
            callback(json, error);
        }];
    }];
}

- (void)precheckWithContinueBlock:(void (^)(NSError*))callback
{
    while(self.loginInProgress)
    {
        if([NSThread isMainThread])
        {
            return;
        }
        [NSThread sleepForTimeInterval:2];
    }
    if(!self.currentSessionToken || self.currentSessionToken.length <= 0)
    {
        // no session available, login
        [self loginApplication:self.applicationToken callBlock:^(NSDictionary *json, NSError *error){
            if(error)
            {
                self.connectionProblems = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kDS_DSS_AUTH_ERROR object:error];
                return;
            }
            callback(nil);
        }];
    }
    else
    {
        callback(nil);
    }
}

- (void)getStructureWithCustomSceneNames:(void (^)(NSDictionary*, NSError*))callback
{
    [self precheckWithContinueBlock:^(NSError *error){
        [[NSNotificationCenter defaultCenter] postNotificationName:kDS_START_LOADING_STRUCTURE object:nil];
        
        [self jsonCall:@"/json/apartment/getStructure" params:[NSDictionary dictionaryWithObject:self.currentSessionToken forKey:@"token"] completionHandler:^(NSDictionary *json, NSError *error){
            
            if(!error)
            {
                self.lastLoadesStructure = json;
                [[self userDefaultsProxy] setObject:self.lastLoadesStructure forKey:kMDDSSMANAGER_LAST_LOADED_STRUCTURE];
                [self persist];
            }
            
            NSDictionary *params = @{ @"token": self.currentSessionToken, @"query": @"/apartment/zones/*(ZoneID,scenes)/groups/*(group)/scenes/*(scene,name)"};
            [self jsonCall:@"/json/property/query" params:params completionHandler:^(NSDictionary *jsonSceneNames, NSError *error){
                self.customSceneNameJSONCache = jsonSceneNames;
                [[self userDefaultsProxy] setObject:self.customSceneNameJSONCache forKey:kMDDSSMANAGER_LAST_LOADED_CUSTROM_SCENE_NAMES_STRUCTURE];
                [self persist];
                callback(json, error);
            }];
        }];
    }];
}

- (void)loadLastLoadesStructure
{
    self.customSceneNameJSONCache = [[self userDefaultsProxy] objectForKey:kMDDSSMANAGER_LAST_LOADED_CUSTROM_SCENE_NAMES_STRUCTURE];
    self.lastLoadesStructure = [[self userDefaultsProxy] objectForKey:kMDDSSMANAGER_LAST_LOADED_STRUCTURE];
}

- (void)getValueOfDSID:(NSString *)dsid callback:(void (^)(int, NSError*))callback
{
    [self precheckWithContinueBlock:^(NSError *error){
        NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid": dsid, @"class" : @"64", @"index": @"0" };
        [self jsonCall:@"/json/device/getConfig" params:params completionHandler:^(NSDictionary *json, NSError *error){
            
#ifdef DDDEBUG
            DDLogDebug(@"%@", json);
#endif
            
            if(json && [json objectForKey:@"result"] && [[json objectForKey:@"result"] objectForKey:@"value"])
            {
                callback([(NSNumber *)[[json objectForKey:@"result"] objectForKey:@"value"] intValue], nil);
            }
            else
            {
                callback(0, error);
            }
            
        }];
    }];
}

- (void)setValueOfDSID:(NSString *)dsid value:(NSString *)value callback:(void (^)(NSDictionary *, NSError*))callback
{
    [self precheckWithContinueBlock:^(NSError *error){
        NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid": dsid, @"value": value };
        [self jsonCall:@"/json/device/setValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
            
    #ifdef DDDEBUG
            DDLogDebug(@"%@", json);
    #endif
            callback(json, error);
        }];
    }];
}

- (void)saveSceneForDevice:(NSString *)dsid scene:(NSString *)scene callback:(void (^)(NSDictionary *, NSError*))callback
{
    [self precheckWithContinueBlock:^(NSError *error){
        NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid": dsid, @"sceneNumber": scene };
        [self jsonCall:@"/json/device/saveScene" params:params completionHandler:^(NSDictionary *json, NSError *error){
            
#ifdef DDDEBUG
            DDLogDebug(@"%@", json);
#endif
            callback(json, error);
        }];
    }];
}

- (void)callScene:(NSString *)sceneNumber zoneId:(NSString *)zoneId groupID:(NSString *)groupID callback:(void (^)(NSDictionary*, NSError*))callback
{
    
    [self precheckWithContinueBlock:^(NSError *error){
        NSDictionary *params = @{ @"token": self.currentSessionToken, @"id":zoneId,@"groupID":groupID, @"sceneNumber":sceneNumber  };
        [self jsonCall:@"/json/zone/callScene" params:params completionHandler:^(NSDictionary *json, NSError *error){
            callback(json, error);
        }];
    }];
}

- (void)callScene:(NSString *)sceneNumber deviceId:(NSString *)deviceId callback:(void (^)(NSDictionary*, NSError*))callback
{
    
    [self precheckWithContinueBlock:^(NSError *error){
        NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":deviceId, @"sceneNumber":sceneNumber  };
        [self jsonCall:@"/json/device/callScene" params:params completionHandler:^(NSDictionary *json, NSError *error){
            callback(json, error);
        }];
    }];
}

- (void)lastCalledSceneInZoneId:(NSString *)zoneId groupID:(NSString *)groupID callback:(void (^)(NSDictionary*, NSError*))callback
{
    
    [self precheckWithContinueBlock:^(NSError *error){
        NSDictionary *params = @{ @"token": self.currentSessionToken, @"id":zoneId, @"groupID":groupID };
        [self jsonCall:@"/json/zone/getLastCalledScene" params:params completionHandler:^(NSDictionary *json, NSError *error){
            callback(json, error);
        }];
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

- (void)dimZone:(NSString *)zoneId groupID:(NSString *)groupID value:(float)value callback:(void (^)(NSDictionary*, NSError*))callback
{
    
#ifdef DDDEBUG
    DDLogVerbose(@"DimZone to: %f", value);
#endif
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"id":zoneId,@"groupID":groupID, @"value":[NSNumber numberWithInt:(int)(value*100)]  };
    [self jsonCall:@"/json/zone/setValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
#ifdef DDDEBUG
        DDLogVerbose(@"DimZone end");
#endif
        callback(json, error);
    }];
}

- (void)zoneGetName:(NSString *)zoneId
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"id":zoneId};
    [self jsonCall:@"/json/zone/getName" params:params completionHandler:^(NSDictionary *json, NSError *error){
        
#ifdef DDDEBUG
        DDLogDebug(@"%@", json);
#endif
        
        
    }];
}

- (void)getSensorValues:(NSString *)dSID
{
    
    NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":dSID, @"sensorIndex": [NSNumber numberWithInt:1]};
    [self jsonCall:@"/json/device/getSensorValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
        
#ifdef DDDEBUG
        DDLogDebug(@"%@", json);
#endif
        
        NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":dSID, @"sensorIndex": [NSNumber numberWithInt:2]};
        [self jsonCall:@"/json/device/getSensorValue" params:params completionHandler:^(NSDictionary *json, NSError *error){

#ifdef DDDEBUG
            DDLogDebug(@"%@", json);
#endif
            
            NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":dSID, @"sensorIndex": [NSNumber numberWithInt:3]};
            [self jsonCall:@"/json/device/getSensorValue" params:params completionHandler:^(NSDictionary *json, NSError *error){

#ifdef DDDEBUG
                DDLogDebug(@"%@", json);
#endif
                
                NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":dSID, @"sensorIndex": [NSNumber numberWithInt:4]};
                [self jsonCall:@"/json/device/getSensorValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
                    
#ifdef DDDEBUG
                    DDLogDebug(@"%@", json);
#endif
                    NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":dSID, @"sensorIndex": [NSNumber numberWithInt:5]};
                    [self jsonCall:@"/json/device/getSensorValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
#ifdef DDDEBUG
                        DDLogDebug(@"%@", json);
#endif
                        NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid":dSID, @"sensorIndex": [NSNumber numberWithInt:6]};
                        [self jsonCall:@"/json/device/getSensorValue" params:params completionHandler:^(NSDictionary *json, NSError *error){
#ifdef DDDEBUG
                            DDLogDebug(@"%@", json);
#endif
                            
                        }];
                    }];
                }];
            }];
        }];
        
    }];
}


- (void)setSensorTable
{
    NSString *dSID = @"3504175fe00000000006553a";
    NSDictionary *params = @{ @"token": self.currentSessionToken,
                              
                              @"dsid":dSID,
                              @"eventIndex": [NSNumber numberWithInt:1],
                              @"eventName": @"Zwischenstecker-aus",
                              @"sensorIndex": [NSNumber numberWithInt:2],
                              @"test": [NSNumber numberWithInt:1],
                              @"value": [NSNumber numberWithInt:3],
                              @"hysteresis": [NSNumber numberWithInt:1],
                              @"validity": [NSNumber numberWithInt:2],
                              @"action": [NSNumber numberWithInt:0]
                              };
    [self jsonCall:@"/json/device/setSensorEventTableEntry" params:params completionHandler:^(NSDictionary *json, NSError *error){
#ifdef DDDEBUG
        DDLogVerbose(@"%@", json);
#endif
    }];
    
    //setSensorEventTableEntry?_dc=1404910928359&dsid=3504175fe00000000006ef99&eventIndex=1&eventName=Bastelklemme%20aus&sensorIndex=2&test=1&value=20&hysteresis=10&validity=2&action=0
}

- (void)resetToDefaults
{
    [self.userDefaultsProxy removeObjectForKey:kMDDSSMANAGER_HOST_UD_KEY];
    [self.userDefaultsProxy removeObjectForKey:kMDDSSMANAGER_APPLICATION_TOKEN_UD_KEY];
    [self persist];
    
    self.applicationToken = @"";
    self.currentSessionToken = @"";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMD_NOTIFICATION_HOST_DID_CHANGE object:self.host];
}

- (BOOL)hasCustomSceneNamesForGroup:(int)searchGroup inZone:(int)forZoneId
{
    if(!self.customSceneNameJSONCache)
    {
        return NO;
    }
    
    for(NSDictionary *zone in [[self.customSceneNameJSONCache objectForKey:@"result"] objectForKey:@"zones"])
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
    if(!self.customSceneNameJSONCache)
    {
        return nil;
    }
    
    for(NSDictionary *zone in [[self.customSceneNameJSONCache objectForKey:@"result"] objectForKey:@"zones"])
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

#pragma mark - metering

- (void)getCircuits:(void (^)(NSDictionary*, NSError*))callback
{
    
//    NSURL *file = [[NSBundle mainBundle] URLForResource:@"circuits.txt" withExtension:@""];
//    NSData *testResponse = [NSData dataWithContentsOfURL:file];
//    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:testResponse options:NSJSONReadingMutableContainers error:nil];
//    
//    callback(jsonArray, nil);
//    return;
    [self precheckWithContinueBlock:^(NSError *error){
        NSDictionary *params = @{ @"token": self.currentSessionToken};
        [self jsonCall:@"/json/apartment/getCircuits" params:params completionHandler:^(NSDictionary *json, NSError *error){
            callback(json, error);
        }];
    }];
}


- (void)getConsumptionLevelsLatest:(void (^)(NSDictionary*, NSError*))callback
{
//    NSURL *file = [[NSBundle mainBundle] URLForResource:@"latest.txt" withExtension:@""];
//    NSData *testResponse = [NSData dataWithContentsOfURL:file];
//    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:testResponse options:NSJSONReadingMutableContainers error:nil];
//    
//    callback(jsonArray, nil);
//    return;
//    
    [self precheckWithContinueBlock:^(NSError *error){
        NSDictionary *params = @{ @"token": self.currentSessionToken, @"from":@"all", @"type": @"consumption"};
        [self jsonCall:@"/json/metering/getLatest" params:params completionHandler:^(NSDictionary *json, NSError *error){
            callback(json, error);
        }];
    }];
}

- (void)getConsumptionLevelsDSID:(NSString *)dsid callback:(void (^)(NSDictionary*, NSError*))callback
{
    
//    NSURL *file = [[NSBundle mainBundle] URLForResource:@"values.txt" withExtension:@""];
//    NSData *testResponse = [NSData dataWithContentsOfURL:file];
//    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:testResponse options:NSJSONReadingMutableContainers error:nil];
//    
//    callback(jsonArray, nil);
//    return;
    
    [self precheckWithContinueBlock:^(NSError *error){
        NSDictionary *params = @{ @"token": self.currentSessionToken, @"dsid": dsid, @"valueCount": self.consumptionHistoryValueCount , @"type": @"consumption", @"resolution" : [NSNumber numberWithInt:60]};
        [self jsonCall:@"/json/metering/getValues" params:params completionHandler:^(NSDictionary *json, NSError *error){
            callback(json, error);
        }];
    }];
}

- (void)setConsumptionHistoryValueCount:(NSNumber *)consumptionHistoryValueCount
{
    _consumptionHistoryValueCount = consumptionHistoryValueCount;
    
    [self.userDefaultsProxy setObject:_consumptionHistoryValueCount forKey:kMDDSSMANAGER_HISTORY_VALUE_COUNT];
    [self persist];
}

- (NSNumber *)consumptionHistoryValueCount
{
    return _consumptionHistoryValueCount;
}

#pragma mark - RemoteConnectivityStack

- (void)checkRemoteConnectivityFor:(NSString *)username password:(NSString *)password callback:(void (^)(NSDictionary*, NSError*))callback
{
    NSDictionary *params = @{ @"user": username, @"password" : password, @"mobileAppUuid": self.appUUID, @"appName": self.appName, @"mobileName": @"TestApp"};
    
    [MDDSSURLConnection jsonConnectionToHostWithPort:@"dsservices.aizo.com" path:@"public/accessmanagement/V1_0/RemoteConnectivity/GetRelayLinkAndToken" params:params HTTPPost:YES completionHandler:^(NSDictionary *json, NSError *error){
        
        @try {
            if([json objectForKey:@"Response"] && [[json objectForKey:@"Response"] objectForKey:@"Token"])
            {
                self.applicationToken = [[json objectForKey:@"Response"] objectForKey:@"Token"];
                [self persistApplicationToken];
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        
        callback(json,error);
        
    }];
}

- (void)loginUser:(NSString *)username password:(NSString *)password callBlock:(void (^)(NSDictionary*, NSError*))handler
{
    NSDictionary *params = @{ @"user": username, @"password" : password};
    
    [self jsonCall:@"/json/system/login" params:params completionHandler:^(NSDictionary *json, NSError *error){
        
        if([json objectForKey:@"result"] && [[json objectForKey:@"result"] objectForKey:@"token"])
        {
            self.currentSessionToken = [[json objectForKey:@"result"] objectForKey:@"token"];
        }
        
        handler(json, error);
        
    }];
}

- (void)enableToken:(NSString *)applicationToken callBlock:(void (^)(NSDictionary*, NSError*))handler
{
    NSDictionary *params = @{ @"applicationToken": applicationToken};
    [self jsonCall:@"/json/system/enableToken" params:params completionHandler:^(NSDictionary *json, NSError *error){
        handler(json, error);
    }];
}

- (void)logoutUser:(void (^)(NSDictionary*, NSError*))handler
{
    [self jsonCall:@"/json/system/logout" params:@{} completionHandler:^(NSDictionary *json, NSError *error){
        
        self.currentSessionToken = nil;
        
        handler(json, error);
        
    }];
}


@end
