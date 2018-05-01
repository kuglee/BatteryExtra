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
#import "CoreMenu.h"

int getDefaultPositionOnMenuBarOfMenuExtraBundle(NSBundle *menuExtraBundle) {
  // The default positions of the built-in Menu Extras are stored in the
  // Extras.plist of the SystemUiServer app.
  NSBundle *systemUIServerBundle = [NSBundle
      bundleWithPath:@"/System/Library/CoreServices/SystemUIServer.app"];
  NSArray *extrasArray =
      [NSArray arrayWithContentsOfFile:[systemUIServerBundle
                                           pathForResource:@"Extras.plist"
                                                    ofType:nil]];

  int position = -1;

  for (NSDictionary *extraDict in extrasArray) {
    if ([extraDict[@"path"] isEqualToString:menuExtraBundle.bundlePath]) {
      // The "id" of the menu extra is used as the position.
      position = [extraDict[@"id"] intValue];
    }
  }

  return position;
}

@implementation ReloadHelper
- (void)getMenuExtraWithBundlePath:(NSString *)menuExtraBundlePath
                         withReply:(void (^)(BOOL))reply {
  NSBundle *menuExtraBundle = [NSBundle bundleWithPath:menuExtraBundlePath];

  if ([CoreMenu getMenuExtra:menuExtraBundle] == nil) {
    reply(NO);
    return;
  }

  reply(YES);
}

- (void)reloadMenuExtraWithBundlePath:(NSString *)menuExtraBundlePath
                            withReply:(void (^)(BOOL))reply {

  NSBundle *menuExtraBundle = [NSBundle bundleWithPath:menuExtraBundlePath];

  int position = getDefaultPositionOnMenuBarOfMenuExtraBundle(menuExtraBundle);
  if (position == -1) {
    reply(NO);
    return;
  }

  // Battery menu extra has to be reloaded twice to function properly.
  // See rdar://32445578 for more information.
  BOOL success = [CoreMenu removeMenuExtra:menuExtraBundle] &&
                 [CoreMenu addMenuExtra:menuExtraBundle atPosition:position] &&
                 [CoreMenu removeMenuExtra:menuExtraBundle];

  if (success) {
    // Sleep is needed because if the Battery menu is added too fast it won't
    // function properly.
    // See rdar://32445578 for more information.
    [NSThread sleepForTimeInterval:1];
    success = [CoreMenu addMenuExtra:menuExtraBundle atPosition:position];
  }

  reply(success);
}

@end
