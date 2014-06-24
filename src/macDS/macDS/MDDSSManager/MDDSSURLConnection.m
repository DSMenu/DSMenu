//
//  MDDSSURLConnection.m
//  macDS
//
//  Created by Jonas Schnelli on 24.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDDSSURLConnection.h"

@interface MDDSSURLConnection ()
@property NSMutableData *connectionData;
@property (nonatomic, copy) void (^handler)(NSDictionary*, NSError*);
@end

@implementation MDDSSURLConnection

+(instancetype)jsonConnectionWithPath:(NSString *)path params:(NSDictionary *)params completionHandler:(void (^)(NSDictionary*, NSError*))handler
{
    MDDSSURLConnection *connection = [[MDDSSURLConnection alloc] init];
    connection.handler = handler;
    [connection callJSON:path params:params];
    return connection;
}



- (void)callJSON:(NSString *)path params:(NSDictionary *)params
{
    NSMutableString *pathString = [path mutableCopy];
    if(params.allKeys.count > 0) { [pathString appendFormat:@"?"]; }
    
    for(NSString *key in params.allKeys)
    {
        [pathString appendFormat:@"%@=%@&", key, [params objectForKey:key]];
    }
    
    NSString *baseURL = @"https://10.0.1.19:8080/"; //TODO
    NSString *fullURLAsString = [baseURL stringByAppendingString:pathString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fullURLAsString]];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - NSURLConnection Stack

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.connectionData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.connectionData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *jsonResponse = [[NSString alloc] initWithData:self.connectionData encoding:NSUTF8StringEncoding];
    
    NSError *e = nil;
    NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:self.connectionData options:NSJSONReadingMutableContainers error:&e];
    
    
    self.handler(jsonArray, e);
    
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end
