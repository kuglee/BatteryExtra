/*
 * Copyright (c) Gábor Librecz <kuglee@gmail.com>
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://www.wtfpl.net/ for more details.
 */

#import <Foundation/Foundation.h>
#import "BatteryExtra-Swift.h"

@interface Loader : NSObject
@end

// The initialization of the plugin if done in Objective-C because using
// the initialize method is not allowed in Swift.
@implementation Loader

+ (void)load {
  [SIMBLPlugin initializePlugin];
}

@end
