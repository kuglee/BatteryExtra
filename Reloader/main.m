/*
 * Copyright (c) 2017 Gábor Librecz <kuglee@gmail.com>
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://www.wtfpl.net/ for more details.
 */

#import <Foundation/Foundation.h>

int CoreMenuExtraGetMenuExtra(CFStringRef identifier, void *menuExtra);
int CoreMenuExtraAddMenuExtra(CFURLRef path, int position, int arg2, int arg3,
                              int arg4, int arg5);
int CoreMenuExtraRemoveMenuExtra(void *menuExtra, int arg1);

int main(int argc, const char *argv[]) {
  @autoreleasepool {

    NSBundle *bundle = [NSBundle
        bundleWithPath:@"/System/Library/CoreServices/SystemUIServer.app"];
    NSArray *extras =
        [NSArray arrayWithContentsOfFile:[bundle pathForResource:@"Extras.plist"
                                                          ofType:nil]];

    NSString *ID = @"";
    for (NSDictionary *extra in extras) {
      if ([extra[@"path"]
              isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
        ID = extra[@"id"];
      }
    }

    NSURL *menu =
        [NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[1]]];

    void *menuExtra = NULL;
    if ((CoreMenuExtraGetMenuExtra(
             (__bridge CFStringRef)[NSString stringWithUTF8String:argv[2]],
             &menuExtra) == 0) &&
        menuExtra) {
      CoreMenuExtraRemoveMenuExtra(menuExtra, 0);

      CoreMenuExtraAddMenuExtra((__bridge CFURLRef)menu, [ID intValue], 0, 0, 0,
                                0);

      return 0;
    }
    
  }

  return 1;
}
