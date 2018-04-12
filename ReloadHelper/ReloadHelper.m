/*
 * Copyright (c) Gábor Librecz <kuglee@gmail.com>
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://www.wtfpl.net/ for more details.
 */

#import "ReloadHelper.h"

int CoreMenuExtraGetMenuExtra(CFStringRef identifier, void *menuExtra);
int CoreMenuExtraAddMenuExtra(CFURLRef path, int position, int arg2, int arg3,
                              int arg4, int arg5);
int CoreMenuExtraRemoveMenuExtra(void *menuExtra, int arg2);

void *getMenuExtra(NSString *bundleIdentifier) {
  void *menuExtra = NULL;
  CoreMenuExtraGetMenuExtra((__bridge CFStringRef)bundleIdentifier, &menuExtra);

  return menuExtra;
}

void removeMenuExtra(NSString *bundleIdentifier) {
  void *menuExtra = getMenuExtra(bundleIdentifier);
  if (menuExtra)
    CoreMenuExtraRemoveMenuExtra(menuExtra, 0);
}

int getMenuExtraBundleID(NSString *bundlePath) {
  NSBundle *bundle = [NSBundle
      bundleWithPath:@"/System/Library/CoreServices/SystemUIServer.app"];
  NSArray *extras =
      [NSArray arrayWithContentsOfFile:[bundle pathForResource:@"Extras.plist"
                                                        ofType:nil]];
  NSString *ID = @"";

  for (NSDictionary *extra in extras) {
    if ([extra[@"path"] isEqualToString:bundlePath])
      ID = extra[@"id"];
  }

  return [ID intValue];
}

void addMenuExtra(NSString *bundlePath) {
  NSURL *menu = [NSURL fileURLWithPath:bundlePath];
  int ID = getMenuExtraBundleID(bundlePath);

  CoreMenuExtraAddMenuExtra((__bridge CFURLRef)menu, ID, 0, 0, 0, 0);
}

@implementation ReloadHelper

- (void)reloadMenuExtraWithPath:(NSString *)menuExtraBundlePath
                 withCompletion:(void (^)(BOOL success))completionHandler {
  NSBundle *menuExtraBundle = [NSBundle bundleWithPath:menuExtraBundlePath];

  void *menuExtra = getMenuExtra([menuExtraBundle bundleIdentifier]);
  if (menuExtra) {

    // Battery menu has to be reloaded twice to function properly
    // (rdar://32445578)
    removeMenuExtra([menuExtraBundle bundleIdentifier]);
    addMenuExtra([menuExtraBundle bundlePath]);
    removeMenuExtra([menuExtraBundle bundleIdentifier]);

    // Without this sleep the Battery menu won't function properly
    // (rdar://32445578)
    [NSThread sleepForTimeInterval:1];
    addMenuExtra([menuExtraBundle bundlePath]);
  }

  void *newMenuExtra = getMenuExtra([menuExtraBundle bundleIdentifier]);
  if (newMenuExtra && newMenuExtra != menuExtra)
    completionHandler(YES);
  else
    completionHandler(NO);
}

@end
