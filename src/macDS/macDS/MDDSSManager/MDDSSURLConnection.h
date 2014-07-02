//
//  MDDSSURLConnection.h
//  macDS
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  MDDSSURLConnection class. Inet connection layer.
 */


@interface MDDSSURLConnection : NSObject

/**
 * Create a instance of MDDSSURLConnection, calls the dSS (async) and parses the json response.
 * The result will be passed to the completionHandler (block)
 */
+(instancetype)jsonConnectionToHostWithPort:(NSString *)hostAndPort path:(NSString *)path params:(NSDictionary *)params completionHandler:(void (^)(NSDictionary*, NSError*))handler;

@end
