//
//  MDDSSManager.h
//  DSMenu
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

/**
 * \ingroup core
 */

#import <Foundation/Foundation.h>

/**
 *  DSSManager class. Layer between App and INet Connection
 */

@interface MDDSSManager : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

/**
 * application name which then will be visible to system/acess in dSS menu
 * Details.
 */
@property NSString *appName;
@property NSString *appUUID;

@property NSString *host; /**< Host to connect with (without https://). */
@property NSString *port;
@property (readonly) BOOL hasApplicationToken; /**< can be accessed to see if there is registered app token */
@property NSString *applicationToken;
@property NSString *dSSVersionString; /**< last known version string (will be be store on disk!) */
@property BOOL useIPAddress; /**< (temp) bool for leeting the preference pannel known if user has set a ip manual of by choosing from the mDNS browser  */ //FIXME

@property BOOL useRemoteConnectivity;
@property NSString *remoteConnectivityUsername;

@property BOOL connectionProblems;

@property BOOL useLastCalledSceneCheck;
@property BOOL suppressAuthError;

@property BOOL loginInProgress;

@property NSDictionary *customSceneNameJSONCache; /**< persisted JSON from last loaded custom scene names */
@property NSDictionary *lastLoadesStructure; /**< persisted JSON from last loaded structure (with scene names) */

@property NSUserDefaults *currentUserDefaults;
- (void)loadDefaults; /**< load the data from the defaults (persisted storage a.k.a. disk) */

@property (strong) NSNumber *consumptionHistoryValueCount; /**< how many values for the history should be loaded, 600 per default */

+ (MDDSSManager *)defaultManager; /**< singleton */

/**
 * set a/the host and persist it
 */
- (void)setAndPersistHost:(NSString *)host;

/**
 * check if behind a host is a dSS
 */
- (void)checkHost:(NSString *)host callback:(void (^)(BOOL))handler;

/**
 * load the versionstring from dSS
 */
- (void)getVersion:(void (^)(NSDictionary*, NSError*))callback;

/**
 * get the appartment structure
 */
- (void)getStructure:(void (^)(NSDictionary*, NSError*))callback;

/**
 * get the appartment structure including user defined scene names
 */
- (void)getStructureWithCustomSceneNames:(void (^)(NSDictionary*, NSError*))callback;

/**
 * request a application token
 */
- (void)requestApplicationToken:(void (^)(NSDictionary*, NSError*))callback;

/**
 * call a scene on a zone
 */
- (void)callScene:(NSString *)sceneNumber zoneId:(NSString *)zoneId groupID:(NSString *)groupID callback:(void (^)(NSDictionary*, NSError*))callback;

/**
 * call a scene on a device
 */
- (void)callScene:(NSString *)sceneNumber deviceId:(NSString *)deviceId callback:(void (^)(NSDictionary*, NSError*))callback;

/**
 * get custom scene names for a zone/group
 */
- (NSArray *)customSceneNamesForGroup:(int)forGroup inZone:(int)forZoneId;

/**
 * get the last called scene
 */
- (void)lastCalledSceneInZoneId:(NSString *)zoneId groupID:(NSString *)groupID callback:(void (^)(NSDictionary*, NSError*))callback;

/**
 * reset host/token/etc. to default (will persist!)
 */
- (void)resetToDefaults;

- (void)getSensorValues:(NSString *)dSID;
- (void)setSensorTable;

- (void)turnOnDeviceId:(NSString *)deviceId callback:(void (^)(NSDictionary*, NSError*))callback;
- (void)turnOffDeviceId:(NSString *)deviceId callback:(void (^)(NSDictionary*, NSError*))callback;

- (void)dimZone:(NSString *)zoneId groupID:(NSString *)groupID value:(float)value callback:(void (^)(NSDictionary*, NSError*))callback;

- (void)getConsumptionLevelsLatest:(void (^)(NSDictionary*, NSError*))callback;
- (void)getConsumptionLevelsDSID:(NSString *)dsid callback:(void (^)(NSDictionary*, NSError*))callback;
- (void)getCircuits:(void (^)(NSDictionary*, NSError*))callback;

- (void)getValueOfDSID:(NSString *)dsid callback:(void (^)(int, NSError*))callback;
- (void)setValueOfDSID:(NSString *)dsid value:(NSString *)value callback:(void (^)(NSDictionary *, NSError*))callback;
- (void)saveSceneForDevice:(NSString *)dsid scene:(NSString *)scene callback:(void (^)(NSDictionary *, NSError*))callback;

#pragma mark - RemoteConnectivityStack
- (void)checkRemoteConnectivityFor:(NSString *)username password:(NSString *)password callback:(void (^)(NSDictionary*, NSError*))callback;
- (void)enableToken:(NSString *)applicationToken callBlock:(void (^)(NSDictionary*, NSError*))handler;
- (void)loginUser:(NSString *)username password:(NSString *)password callBlock:(void (^)(NSDictionary*, NSError*))handler;
- (void)logoutUser:(void (^)(NSDictionary*, NSError*))handler;
- (void)loginApplication:(NSString *)loginToken callBlock:(void (^)(NSDictionary*, NSError*))handler;
@end
