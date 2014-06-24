//
//  MDDSSManager.h
//  macDS
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDDSSManager : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

+ (MDDSSManager *)defaultManager;
- (void)loginApplication:(NSString *)loginToken;
@end
