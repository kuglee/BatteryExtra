/*
 * Copyright (c) Gábor Librecz <kuglee@gmail.com>
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://www.wtfpl.net/ for more details.
 */

#import "ZKSwizzle.h"
#import <AppKit/AppKit.h>

@interface MyBatteryViewInMenu : NSView
@end

@implementation MyBatteryViewInMenu
extern BOOL hideIcon;
float *batteryRectWidth;

- (id)initWithFrame:(NSRect)arg1 andBundle:(id)arg2 {
  batteryRectWidth = &ZKHookIvar(self, float, "_batteryRectWidth");

  return ZKOrig(id, arg1, arg2);
}

- (void)updateInfo {
  ZKOrig(void);

  // Changes the width of the battery icon in order to hide it.
  if (hideIcon)
    *batteryRectWidth = 0;
}

@end
