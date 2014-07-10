//
//  MDDSSManager.h
//  macDS
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

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

@property NSString *host; /**< Host to connect with (without https://). */
@property NSString *port;
@property (readonly) BOOL hasApplicationToken; /**< can be accessed to see if there is registered app token */
@property NSString *applicationToken;
@property NSString *dSSVersionString; /**< last known version string (will be be store on disk!) */
@property BOOL useIPAddress; /**< (temp) bool for leeting the preference pannel known if user has set a ip manual of by choosing from the mDNS browser  */ //FIXME

+ (MDDSSManager *)defaultManager; /**< singleton */

/**
 * set a/the host and persist it
 */
- (void)setAndPersistHost:(NSString *)host;

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
 * reset host/token/etc. to default (will persist!)
 */
- (void)resetToDefaults;

- (void)getSensorValues:(NSString *)dSID;
- (void)setSensorTable;

- (void)turnOnDeviceId:(NSString *)deviceId callback:(void (^)(NSDictionary*, NSError*))callback;
- (void)turnOffDeviceId:(NSString *)deviceId callback:(void (^)(NSDictionary*, NSError*))callback;

- (void)getEnergyLevelsLatest:(void (^)(NSDictionary*, NSError*))callback;
- (void)getEnergyLevelsDSID:(NSString *)dsid callback:(void (^)(NSDictionary*, NSError*))callback;
- (void)getCircuits:(void (^)(NSDictionary*, NSError*))callback;
@end
