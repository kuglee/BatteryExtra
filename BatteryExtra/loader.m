
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
#import "ReloadHelperProtocol.h"
#import "ZKSwizzle.h"

@protocol SUISDocklingServerController
@end

@interface BatterySUISStartupObject
    : NSObject <SUISDocklingServerController, NSApplicationDelegate,
                NSFileManagerDelegate>
@end

@implementation BatterySUISStartupObject

NSBundle *mainBundle; // BatteryExtra needs this to be global

// Cannot do reloading directly because of sandboxing
+ (void)reloadMenuExtra:(NSString *)menuExtraBundlePath
         withCompletion:(void (^)(BOOL success))completionHandler {
  NSXPCConnection *_connectionToService =
      [[NSXPCConnection alloc] initWithServiceName:@"com.kuglee.BatteryExtra.ReloadHelper"];
  _connectionToService.remoteObjectInterface =
      [NSXPCInterface interfaceWithProtocol:@protocol(ReloadHelperProtocol)];
  [_connectionToService resume];

  [[_connectionToService remoteObjectProxy]
      reloadMenuExtraWithPath:menuExtraBundlePath
               withCompletion:^(BOOL success) {
                 completionHandler(success);
               }];
}

+ (void)swizzleMenuExtra:(Class)menuExtra
          withCompletion:(void (^)(BOOL success))completionHandler {

  BOOL didSwizzle = _ZKSwizzle(NSClassFromString(@"MyBatteryExtra"), menuExtra);
  didSwizzle &= ZKSwizzle(MyBatteryViewInMenu, BatteryViewInMenu);

  if (didSwizzle)
    completionHandler(YES);
  else
    completionHandler(NO);
}

+ (void)load {
  mainBundle = [NSBundle bundleForClass:self];
  NSString *mainBundleName =
      [[mainBundle infoDictionary] objectForKey:@"CFBundleName"];

  NSString *menuExtraBundlePath =
      [[mainBundle infoDictionary] objectForKey:@"NSMenuExtraBundle"];
  NSBundle *menuExtraBundle = [NSBundle bundleWithPath:menuExtraBundlePath];
  NSString *menuExtraBundleName =
      [[menuExtraBundle infoDictionary] objectForKey:@"CFBundleName"];

  NSLog(@"%@: Swizzling SystemUIServer...", mainBundleName);
  BOOL didSwizzle = ZKSwizzle(BatterySUISStartupObject, SUISStartupObject);
  if (!didSwizzle) {
    NSLog(@"%@: Could not swizzle SystemUIServer!", mainBundleName);
    return;
  }
  NSLog(@"%@: SystemUIServer was swizzled successfully!", mainBundleName);

  NSLog(@"%@: Swizzling %@...", mainBundleName, menuExtraBundleName);
  [[self class]
      swizzleMenuExtra:[menuExtraBundle principalClass]
        withCompletion:^(BOOL success) {
          if (success) {
            NSLog(@"%@: %@ was swizzled successfully!!", mainBundleName,
                  menuExtraBundleName);

            NSLog(@"%@: Reloading %@...", mainBundleName, menuExtraBundleName);
            [[self class] reloadMenuExtra:menuExtraBundlePath
                           withCompletion:^(BOOL success) {
                             if (success)
                               NSLog(@"%@: %@ was reloaded successfully!",
                                     mainBundleName, menuExtraBundleName);

                             else
                               NSLog(@"%@: Could not reload %@!",
                                     mainBundleName, menuExtraBundleName);
                           }];
          } else
            NSLog(@"%@: Could not swizzle %@!", mainBundleName,
                  menuExtraBundleName);
        }];
}

@end
