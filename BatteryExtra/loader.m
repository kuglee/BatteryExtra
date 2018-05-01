/*
 * Copyright (c) Gábor Librecz <kuglee@gmail.com>
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://www.wtfpl.net/ for more details.
 */

#import <AppKit/AppKit.h>
#import <os/log.h>
#import "ReloadHelper.h"
#import "ZKSwizzle.h"

NSBundle *pluginMainBundle; // BatteryExtra needs this to be global

@interface Loader : NSObject
@end

@implementation Loader
os_log_t pluginLog;

// Cannot do reloading directly because of sandboxing
+ (void)reloadMenuExtraIfVisibleOnMenuBarWithBundlePath:
    (NSString *)menuExtraBundlePath {
  NSXPCConnection *connectionToReioadHeiperService = [[NSXPCConnection alloc]
      initWithServiceName:@"com.kuglee.batteryextra.reloadhelper"];
  connectionToReioadHeiperService.remoteObjectInterface =
      [NSXPCInterface interfaceWithProtocol:@protocol(ReloadHelperProtocol)];
  [connectionToReioadHeiperService resume];

  ReloadHelper *reioadHelperService =
      connectionToReioadHeiperService.remoteObjectProxy;

  [reioadHelperService
      getMenuExtraWithBundlePath:menuExtraBundlePath
                       withReply:^(BOOL success) {
                         if (success) {
                           os_log(pluginLog, "Reloading Menu Extra...");
                           [[connectionToReioadHeiperService remoteObjectProxy]
                               reloadMenuExtraWithBundlePath:menuExtraBundlePath
                                                   withReply:^(BOOL success) {
                                                     if (success)
                                                       os_log(
                                                           pluginLog,
                                                           "The Menu Extra "
                                                           "\"%{public}@ \" "
                                                           "was reloaded "
                                                           "successfully!",
                                                           menuExtraBundlePath);
                                                     else
                                                       os_log_error(
                                                           pluginLog,
                                                           "Could not reload "
                                                           "Menu Extra "
                                                           "\"%{public}@\"!",
                                                           menuExtraBundlePath);

                                                     [connectionToReioadHeiperService
                                                         invalidate];
                                                   }];
                         } else
                           [connectionToReioadHeiperService invalidate];
                       }];
}

+ (BOOL)loadMenuExtraBundleIfNotLoadedWithPath:(NSString *)menuExtraBundlePath {
  BOOL isMenuExtraLoaded = NO;

  for (NSBundle *bundle in NSBundle.allBundles) {
    if ([bundle.bundlePath isEqualToString:menuExtraBundlePath]) {
      isMenuExtraLoaded = YES;
      break;
    }
  }

  // Load the Menu Extra manually if it's not already loaded to be able to
  // swizzle it.
  if (!isMenuExtraLoaded) {
    NSBundle *menuExtraBundle = [NSBundle bundleWithPath:menuExtraBundlePath];
    return [menuExtraBundle load];
  }

  return YES;
}

+ (BOOL)swizzle {
  BOOL didSwizzle = ZKSwizzle(MyBatteryExtra, BatteryExtra) &&
                    ZKSwizzle(MyBatteryViewInMenu, BatteryViewInMenu);

  return didSwizzle;
}

+ (void)load {
  pluginMainBundle = [NSBundle bundleForClass:self];
  pluginLog = os_log_create(pluginMainBundle.bundleIdentifier.UTF8String,
                            "SIMBLPlugin");

  os_log(pluginLog, "Swizzling \"%@\"...",
         NSBundle.mainBundle.bundleIdentifier);

  // The bundle path of the Menu Extra is stored in the Info.plist of the
  // plugin.
  NSString *menuExtraBundlePath =
      [[pluginMainBundle infoDictionary] objectForKey:@"NSMenuExtraBundle"];

  BOOL menuExtraDidLoad =
      [self loadMenuExtraBundleIfNotLoadedWithPath:menuExtraBundlePath];

  if (!menuExtraDidLoad) {
    os_log(pluginLog, "Could not load bundle \"%{public}@\"! Quitting...",
           menuExtraBundlePath);
  }

  BOOL didSwizzle = [self swizzle];

  if (!didSwizzle) {
    os_log_error(pluginLog, "Could not swizzle \"%@\"!",
                 NSBundle.mainBundle.bundleIdentifier);
    return;
  }

  os_log(pluginLog, "\"%@\" was swizzled successfully!",
         NSBundle.mainBundle.bundleIdentifier);

  [self reloadMenuExtraIfVisibleOnMenuBarWithBundlePath:menuExtraBundlePath];
}

@end
