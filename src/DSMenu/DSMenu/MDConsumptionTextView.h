//
//  MDConsumptionTextView.h
//  DSMenu
//
//  Created by Jonas Schnelli on 15.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#if TARGET_OS_IPHONE
#define NSView_OR_UIView UIView
#define NSColor_OR_UIColor UIColor
#else
#define NSView_OR_UIView NSView
#define NSColor_OR_UIColor NSColor
#endif

@interface MDConsumptionTextView : NSView_OR_UIView
@property NSString *textToShow;
@property NSColor_OR_UIColor *textColor;
@end
