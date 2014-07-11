//
//  MDDSSEnegryManager.m
//  macDS
//
//  Created by Jonas Schnelli on 09.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDDSSConsumptionManager.h"
#import "MDDSSManager.h"

static MDDSSConsumptionManager *defaultManager;

@interface MDDSSConsumptionManager ()
@property (strong) NSTimer *refreshTimerLatest;
@property (strong) NSTimer *refreshTimerHistory;
@property BOOL pollInProgressLatest;
@property BOOL pollInProgressHistory;
@property BOOL loadCircuitsInProgress;

@property (strong) NSMutableArray *dSMs;
@property (strong) NSMutableDictionary *historyValues;
@property (strong) NSArray *colors;
@end

@implementation MDDSSConsumptionManager

void MDContextAddRoundedRect(CGContextRef context, CGRect rrect, CGFloat radius)
{

    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    CGContextMoveToPoint(context, minx, midy);
    // Add an arc through 2 to 3
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    // Add an arc through 4 to 5
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    // Add an arc through 6 to 7
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    // Add an arc through 8 to 9
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    // Close the path 
    CGContextClosePath(context);
}

+ (MDDSSConsumptionManager *)defaultManager
{
    if(!defaultManager)
    {
        defaultManager = [[MDDSSConsumptionManager alloc] init];
    }
    return defaultManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pollInProgressLatest   = NO;
        self.pollInProgressHistory  = NO;
        self.loadCircuitsInProgress = NO;
        
        self.historyValues = [[NSMutableDictionary alloc] init];
        self.colors = @[[NSColor redColor], [NSColor cyanColor], [NSColor greenColor], [NSColor blueColor], [NSColor purpleColor], [NSColor yellowColor]];
    }
    return self;
}

- (void)startPollingLatest:(NSInteger)intervallInSeconds
{
    self.refreshTimerLatest = [NSTimer timerWithTimeInterval:intervallInSeconds
                                             target:self
                                           selector:@selector(latestTimerFired:)
                                           userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.refreshTimerLatest forMode:NSRunLoopCommonModes];
    [self.refreshTimerLatest fire];
}

- (void)startPollingHistory:(NSInteger)intervallInSeconds
{
    self.refreshTimerHistory = [NSTimer timerWithTimeInterval:intervallInSeconds
                                                target:self
                                              selector:@selector(historyTimerFired:)
                                              userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.refreshTimerHistory forMode:NSRunLoopCommonModes];
    [self.refreshTimerHistory fire];
}

- (void)stopPollingLatest
{
    [self.refreshTimerLatest invalidate];
    self.refreshTimerLatest = nil;
}

- (void)stopPollingHistory
{
    [self.refreshTimerHistory invalidate];
    self.refreshTimerHistory = nil;
    
    self.historyValues = [[NSMutableDictionary alloc] init];
    
    self.callbackHistory(nil, nil);
}

- (void)latestTimerFired:(id)sender
{
    [self performSelectorInBackground:@selector(pollLatestValuesInBackground) withObject:nil];
}

- (void)historyTimerFired:(id)sender
{
    [self performSelectorInBackground:@selector(pollHistoryValuesInBackground) withObject:nil];
}

- (void)pollLatestValuesInBackground
{
    @autoreleasepool {

        if(self.pollInProgressLatest == NO)
        {
            // copy dSM array synchronized to prevent thread conflicts
            NSArray *dsm = nil;
            @synchronized(self) {
                dsm = [self.dSMs copy];
            }
            if(dsm)
            {
                self.pollInProgressLatest = YES;
     
                [[MDDSSManager defaultManager] getEnergyLevelsLatest:^(NSDictionary *json, NSError *error){
                    self.pollInProgressLatest = NO;
                    
                    if(self.callbackLatest)
                    {
                        dispatch_sync(dispatch_get_main_queue(), ^(){
                            self.callbackLatest([[json objectForKey:@"result"] objectForKey:@"values"], nil);
                        });
                        ;
                    }
                    
                }];
            }
            else
            {
                [self loadCircuits];
            }
            CFRunLoopRun();
        }
     
    }
}

- (void)pollHistoryValuesInBackground
{
    @autoreleasepool {
        
        NSArray *dsm = nil;
        @synchronized(self) {
            dsm = [self.dSMs copy];
        }
        if(dsm)
        {
            
            if(self.pollInProgressHistory == NO)
            {
                self.pollInProgressHistory = YES;
                
                
                [self.historyValues removeAllObjects];
                sleep(2);
                [[MDDSSManager defaultManager] getEnergyLevelsDSID:@".meters(all)" callback:^(NSDictionary *jsonV, NSError *errorV)
                 {
                     if(errorV)
                     {
                         self.pollInProgressHistory = NO;
                     }
                     [self.historyValues setObject:[[jsonV objectForKey:@"result"] objectForKey:@"values"] forKey:@"all"];
                     self.pollInProgressHistory = NO;
                     self.callbackHistory(self.historyValues, self.dSMs);
                 }];
            }
        }
        else
        {
            [self loadCircuits];
        }
        
        
        CFRunLoopRun();
    }
}

- (void)loadCircuits
{
    if(self.loadCircuitsInProgress == NO)
    {
        self.loadCircuitsInProgress = YES;
        [[MDDSSManager defaultManager] getCircuits:^(NSDictionary *json, NSError *error){
            @synchronized(self) {
                self.loadCircuitsInProgress = NO;
                
                self.dSMs = [[[json objectForKey:@"result"] objectForKey:@"circuits"] mutableCopy];
                
                int i = 0;
                for(NSMutableDictionary *dSM in self.dSMs)
                {
                    [dSM setObject:[self.colors objectAtIndex:i] forKey:@"color"];
                    i++;
                }
            }
        }];
    }
}

- (NSString *)dSMNameFromID:(NSString *)dsid
{
    for(NSDictionary *dSM in self.dSMs)
    {
        if([[dSM objectForKey:@"dsid"] isEqualToString:dsid])
        {
            return [dSM objectForKey:@"name"];
        }
    }
    return nil;
}

#pragma mark drawing stack

- (NSTimeInterval)earliestTimestamp
{
    NSTimeInterval ts = DBL_MAX;
    for(NSString *dsid in self.historyValues.allKeys)
    {
        for(NSArray *valueTime in [self.historyValues objectForKey:dsid])
        {
            NSNumber *aTimeStamp = [valueTime objectAtIndex:0];
            if([aTimeStamp doubleValue] < ts)
            {
                ts = [aTimeStamp doubleValue];
            }
        }
    }
    
    return ts;
}

- (double)valueForTime:(NSTimeInterval)ts forDSID:(NSString *)searchDSID
{
    for(NSString *dsid in self.historyValues.allKeys)
    {
        if([dsid isEqualToString:searchDSID])
        {
            for(NSArray *valueTime in [self.historyValues objectForKey:dsid])
            {
                NSNumber *aTimeStamp = [valueTime objectAtIndex:0];
                if([aTimeStamp doubleValue] == ts)
                {
                    return [[valueTime objectAtIndex:1] doubleValue];
                }
            }
            return 0;
        }

    }
    return 0;
}

- (NSString *)referenceDSM
{
    NSString *referenceDSM = nil;
    NSUInteger count = 0;
    for(NSString *dsid in self.historyValues.allKeys)
    {
        if([[self.historyValues objectForKey:dsid] count] > count)
        {
            count = [[self.historyValues objectForKey:dsid] count];
            referenceDSM = dsid;
        }
    }
    return referenceDSM;
}
- (double)maxValue
{
    NSString *referenceDSM = [self referenceDSM];
    
    double maxHeight = 0;
    for(NSArray *timeValue in [self.historyValues objectForKey:referenceDSM])
    {
        NSTimeInterval referenceTS = [(NSNumber *)[timeValue objectAtIndex:0] doubleValue];
        double value = [(NSNumber *)[timeValue objectAtIndex:1] doubleValue];
        double timeHeight = value;
        
        for(NSString *dsid in self.historyValues.allKeys)
        {
            if(![dsid isEqualToString:referenceDSM])
            {
                CGFloat value = [self valueForTime:referenceTS forDSID:dsid];
                timeHeight+=value;
            }
        }
        if(timeHeight > maxHeight)
        {
            maxHeight = timeHeight;
        }
    }
    
    return maxHeight;
}

- (NSColor *)colorForDSM:(NSString *)dsid
{
    NSColor *color = [NSColor colorWithCalibratedRed:1.0000 green:0.1 blue:0.1 alpha:0.8];
    for(NSDictionary *dsm in self.dSMs)
    {
        if([[dsm objectForKey:@"dsid"] isEqualToString:dsid])
        {
            color = [dsm objectForKey:@"color"];
        }
    }
    return color;
}

- (void)drawHistoryOnContext:(CGContextRef)imageContext size:(CGSize)size
{
    BOOL drawOnBitmap = NO;
    
    CGRect padding = CGRectMake(20, 20, 20, 20);
    CGRect paddingRect = CGRectMake(18, 18, 18, 28);
    
    double maxValue = [self maxValue];
    CGFloat cutoff = 0.7;
    double maxHeight = maxValue / cutoff; // /0.7 = 30% empty space at top
    
    float sizeFakt = (size.height-padding.origin.y-padding.size.height)/maxHeight;
    
    // draw image
    if(!imageContext)
    {
        drawOnBitmap = YES;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGSize size = CGSizeMake(300,200);
        NSMutableData *data = [NSMutableData dataWithLength:size.width * size.height * 4];
        imageContext = CGBitmapContextCreate([data mutableBytes],
                                             size.width,
                                             size.height,
                                             8,
                                             size.width * 4,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    }
    
    CGContextSetRGBFillColor(imageContext,0.0,0.0,0.0,1.0);
    MDContextAddRoundedRect(imageContext, CGRectMake(paddingRect.origin.x, paddingRect.origin.y, size.width-paddingRect.size.width-paddingRect.origin.x, size.height-paddingRect.size.height-paddingRect.origin.y), 3);
    CGContextDrawPath(imageContext, kCGPathFill);
    
    
    CGContextSetRGBStrokeColor(imageContext,0.0,0.0,0.6,1.0);
    CGContextSetRGBFillColor(imageContext,0.0,0.0,0.6,1.0);
    CGContextSetLineWidth(imageContext, 1);
    
    
    NSString *referenceDSM = @"all";//[self referenceDSM];
    
    
    CGMutablePathRef aPath = CGPathCreateMutable();
    
    
    
    CGFloat baseX = padding.origin.x;
    CGFloat currentX = baseX;
    NSUInteger valueCount = [[self.historyValues objectForKey:referenceDSM] count];
    

    CGContextSelectFont(imageContext, "Helvetica-Light", 12, kCGEncodingMacRoman);
    
    NSString *titleString = NSLocalizedString(@"lastTwoHours", @"last two hours graph title");
   
    CGContextSetTextDrawingMode(imageContext, kCGTextInvisible);
    CGContextShowTextAtPoint(imageContext, 0, 0, [titleString cStringUsingEncoding:NSUTF8StringEncoding], titleString.length);
    CGPoint pt = CGContextGetTextPosition(imageContext);

    CGContextSetTextDrawingMode(imageContext, kCGTextFill);
    CGContextSetFillColorWithColor(imageContext, [[NSColor grayColor] CGColor]);
    CGContextShowTextAtPoint(imageContext, size.width/2.0-pt.x/2.0, size.height-20,  [titleString cStringUsingEncoding:NSUTF8StringEncoding], titleString.length);
    
    CGContextSelectFont(imageContext, "Helvetica-Light", 10, kCGEncodingMacRoman);
    
    
    if((!self.historyValues) || valueCount <= 0)
    {

        CGContextSetTextDrawingMode(imageContext, kCGTextInvisible);
        
        NSString *loadingText = NSLocalizedString(@"loadingHistory", @"");
        CGContextShowTextAtPoint(imageContext, 0, 0, [loadingText cStringUsingEncoding:NSUTF8StringEncoding], loadingText.length);
        CGPoint pt = CGContextGetTextPosition(imageContext);
        CGContextSetTextDrawingMode(imageContext, kCGTextFill);
        
        CGContextSetFillColorWithColor(imageContext, [[NSColor whiteColor] CGColor]);
        CGContextShowTextAtPoint(imageContext, size.width/2.0-pt.x/2.0, size.height/2.0-10, [loadingText cStringUsingEncoding:NSUTF8StringEncoding], loadingText.length);
    }
    else
    {
        
        CGFloat xStepWidth = (size.width-padding.origin.x-padding.size.width)/(valueCount-1);
        
        for(NSArray *timeValue in [self.historyValues objectForKey:referenceDSM])
        {
            double value = [(NSNumber *)[timeValue objectAtIndex:1] doubleValue];
            
            NSColor *color = [self colorForDSM:referenceDSM];
            CGContextSetRGBFillColor(imageContext,color.redComponent*1.3,color.greenComponent*1.3,color.blueComponent*1.3,0.5);
            CGContextSetRGBStrokeColor(imageContext,color.redComponent,color.greenComponent,color.blueComponent,color.alphaComponent);
            
            
            if(currentX == baseX)
            {
                CGPathMoveToPoint(aPath, NULL, currentX, padding.size.height+value*sizeFakt);
            }
            CGPathAddLineToPoint(aPath, NULL, currentX, padding.size.height+value*sizeFakt);
            
            
            currentX+=xStepWidth;
        }
        
        CGContextAddPath(imageContext, aPath);
        CGContextDrawPath(imageContext, kCGPathStroke);
        
        CGContextAddPath(imageContext, aPath);
        CGContextAddLineToPoint(imageContext, currentX-xStepWidth, padding.size.height);
        CGContextAddLineToPoint(imageContext, baseX, padding.size.height);
        CGContextDrawPath(imageContext, kCGPathFill);
        
        CGContextSetFillColorWithColor(imageContext, [[NSColor whiteColor] CGColor]);
        CGContextShowTextAtPoint(imageContext, paddingRect.origin.x+3, paddingRect.origin.y+5, "0 W", 3);
        NSString *topString = [NSString stringWithFormat:@"%d W", (int)(maxValue/cutoff)+1];
        CGContextShowTextAtPoint(imageContext, paddingRect.origin.x+3, size.height-paddingRect.size.height-10, [topString cStringUsingEncoding:NSUTF8StringEncoding], topString.length);
        
    }
    
    if(drawOnBitmap) {
        CGImageRef imgRef = CGBitmapContextCreateImage(imageContext);
        NSImage *image = [[NSImage alloc] initWithCGImage:imgRef size:NSZeroSize];
        
        NSData *imageData = [image TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        
        imageData = [imageRep representationUsingType:NSPNGFileType properties:nil];
        [imageData writeToFile: @"/Users/jonasschnelli/Desktop/test1.png" atomically: YES];
    }
}

@end
