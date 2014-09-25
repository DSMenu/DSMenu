//
//  MDDSSEnegryManager.h
//  DSMenu
//
//  Created by Jonas Schnelli on 09.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 * MDDSSEnegryManager.
 *  This class handles asynchronous polling of consumption data.
 */
@interface MDDSSConsumptionManager : NSObject

@property (nonatomic, copy) void (^callbackLatest)(NSArray*, NSError*);
@property (nonatomic, copy) void (^callbackHistory)(NSDictionary*, NSArray*);

+ (MDDSSConsumptionManager *)defaultManager;  /**< singleton */


/**
 * start repeatedly polling the dss to get latest consumption values of all dSMs
 */
- (void)startPollingLatest:(NSInteger)intervallInSeconds;

/**
 * start repeatedly polling the dss to get the history consumption values of all dSMs
 */
- (void)startPollingHistory:(NSInteger)intervallInSeconds;

/**
 * stop polling latest data
 */
- (void)stopPollingLatest;

/**
 * stop polling history
 */
- (void)stopPollingHistory;


/**
 * Helper for getting dSM name by dsid out of the cache
 */
- (NSString *)dSMNameFromID:(NSString *)dsid;

/**
 * draw the history on a context
 */
- (void)drawHistoryOnContext:(CGContextRef)imageContext size:(CGSize)size;

/**
 * returns the height (y point) of a certain x pos
 */
- (CGFloat)heightForXValue:(CGFloat)xVal size:(CGSize)size wValue:(double *)wValue time:(double *)time;
@end
