/*
 * Copyright (c) 2017 Gábor Librecz <kuglee@gmail.com>
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://www.wtfpl.net/ for more details.
 */

#import <AppKit/AppKit.h>
#import "ZKSwizzle.h"

@protocol SUISDocklingServerController
@end

@interface BatterySUISStartupObject
    : NSObject <SUISDocklingServerController, NSApplicationDelegate,
                NSFileManagerDelegate>
@end

@implementation BatterySUISStartupObject

NSBundle *mainBundle;
NSString *mainBundleName;

NSBundle *menuExtraBundle;
NSString *menuExtraBundleName;

NSString *helperPath;

// Cannot do reloading directly because of sandboxing
+ (int)reloadMenuExtra {
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath:helperPath];

  [task setArguments:@[
    [menuExtraBundle bundlePath], [menuExtraBundle bundleIdentifier]
  ]];
  [task launch];
  [task waitUntilExit];

  return [task terminationStatus];
}

+ (BOOL)swizzleMenuExtra:(Class)menuExtra {
  NSLog(@"%@: Swizzling %@...", mainBundleName, menuExtraBundleName);

  BOOL didSwizzle = _ZKSwizzle(NSClassFromString(@"MyBatteryExtra"), menuExtra);
  didSwizzle &= ZKSwizzle(MyBatteryViewInMenu, BatteryViewInMenu);

  if (!didSwizzle) {
    NSLog(@"%@: Could not swizzle %@!", mainBundleName, menuExtraBundleName);
    return NO;
  }

  NSLog(@"%@: %@ was swizzled successfully!", mainBundleName,
        menuExtraBundleName);

  return YES;
}

+ (void)load {
  mainBundle = [NSBundle bundleForClass:self];
  mainBundleName = [[mainBundle infoDictionary] objectForKey:@"CFBundleName"];

  NSString *menuExtraBundlePath =
      [[mainBundle infoDictionary] objectForKey:@"NSMenuExtraBundle"];
  menuExtraBundle = [NSBundle bundleWithPath:menuExtraBundlePath];
  menuExtraBundleName =
      [[menuExtraBundle infoDictionary] objectForKey:@"CFBundleName"];

  NSString *helperName =
      [[mainBundle infoDictionary] objectForKey:@"HelperName"];
  helperPath = [mainBundle pathForResource:helperName ofType:nil];

  NSLog(@"%@: Swizzling SystemUIServer...", mainBundleName);

  BOOL didSwizzle = ZKSwizzle(BatterySUISStartupObject, SUISStartupObject);
  if (!didSwizzle) {
    NSLog(@"%@: Could not swizzle SystemUIServer!", mainBundleName);
    return;
  }

  NSLog(@"%@: SystemUIServer was swizzled successfully!", mainBundleName);

  BOOL didSwizzleMenuItem =
      [[self class] swizzleMenuExtra:[menuExtraBundle principalClass]];

  if (didSwizzleMenuItem)
    [[self class] reloadMenuExtra];
}

@end
