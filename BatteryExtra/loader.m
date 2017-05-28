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

NSString *bundleName;
BOOL didSwizzleMenuItem;
NSBundle *menuExtraMainBundle;
NSString *helperPath;

// Cannot do reloading directly because of sandboxing
+ (int)reloadMenuExtra {
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath:helperPath];

  [task setArguments:@[
    [menuExtraMainBundle bundlePath], [menuExtraMainBundle bundleIdentifier]
  ]];
  [task launch];
  [task waitUntilExit];

  return [task terminationStatus];
}

+ (BOOL)swizzleMenuExtra:(Class)menuExtra {
  NSLog(@"%@: Swizzling menuExtra...", bundleName);

  didSwizzleMenuItem =
      _ZKSwizzle(NSClassFromString(@"MyBatteryExtra"), menuExtra);
  if (didSwizzleMenuItem)
    NSLog(@"%@: MenuExtra was swizzled successfully!", bundleName);
  else
    NSLog(@"%@: Could not swizzle menuExtra!", bundleName);

  return didSwizzleMenuItem;
}

+ (void)load {
  NSBundle *mainBundle = [NSBundle bundleForClass:self];
  bundleName = [[mainBundle infoDictionary] objectForKey:@"CFBundleName"];
  NSString *menuExtraBundlePath =
      [[mainBundle infoDictionary] objectForKey:@"NSMenuExtraBundle"];
  menuExtraMainBundle = [NSBundle bundleWithPath:menuExtraBundlePath];
  NSString *helperName =
      [[mainBundle infoDictionary] objectForKey:@"HelperName"];
  helperPath = [mainBundle pathForResource:helperName ofType:nil];

  NSLog(@"%@: Swizzling SystemUIServer...", bundleName);

  BOOL didSwizzle = ZKSwizzle(BatterySUISStartupObject, SUISStartupObject);
  if (didSwizzle)
    NSLog(@"%@: SystemUIServer was swizzled successfully!", bundleName);
  else
    NSLog(@"%@: Could not swizzle SystemUIServer!", bundleName);

  if (didSwizzle && [BatterySUISStartupObject reloadMenuExtra] == 0)
    NSLog(@"%@: SystemUIServer was reloaded successfully!", bundleName);
}

- (id)loadMenuExtra:(id)arg1 withData:(id)arg2 atPosition:(long long)arg3 {
  if (!didSwizzleMenuItem &&
      [arg1 principalClass] == [menuExtraMainBundle principalClass])
    [BatterySUISStartupObject swizzleMenuExtra:[arg1 principalClass]];

  return ZKOrig(id, arg1, arg2, arg3);
}

@end
