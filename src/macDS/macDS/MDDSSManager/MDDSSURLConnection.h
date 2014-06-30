//
//  MDDSSURLConnection.h
//  macDS
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDDSSURLConnection : NSObject

+(instancetype)jsonConnectionToHostWithPort:(NSString *)hostAndPort path:(NSString *)path params:(NSDictionary *)params completionHandler:(void (^)(NSDictionary*, NSError*))handler;

@end
