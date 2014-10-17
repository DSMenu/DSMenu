//
//  MDConsumptionLineView.h
//  DSMenu
//
//  Created by Jonas Schnelli on 15.07.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

/**
 * \ingroup core
 */

#if TARGET_OS_IPHONE
#define NSView_OR_UIView UIView
#define NSColor_OR_UIColor UIColor
#else
#define NSView_OR_UIView NSView
#define NSColor_OR_UIColor NSColor
#endif

@interface MDConsumptionLineView : NSView_OR_UIView
@end
