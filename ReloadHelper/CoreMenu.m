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
#import "CoreMenu.h"

/// A wrapper class of CoreMenu functions for managing menu extras. (From
/// "ApplicationServices/HIServices" framework)
@implementation CoreMenu
/**
 Returns a handle for the menu extra if it is on the menu bar.

 - parameters:
 - menuExtra: The bundle of the menu extra.

 - returns: An optional handle for the menu extra.
 */
+ (void *)getMenuExtra:(NSBundle *)menuExtraBundle {
  void *menuExtraHandle = NULL;

  CoreMenuExtraGetMenuExtra(
      (__bridge CFStringRef)menuExtraBundle.bundleIdentifier, &menuExtraHandle);

  return menuExtraHandle;
}

/**
 Removes the menu extra if it is on the menu bar.

 - parameters:
 - menuExtra: The bundle of the menu extra.

 - returns: A value indicating the success of the operation.
 */
+ (BOOL)removeMenuExtra:(NSBundle *)menuExtraBundle {
  void *menuExtraHandle = [self getMenuExtra:menuExtraBundle];

  if (!menuExtraHandle)
    return NO;

  CoreMenuExtraRemoveMenuExtra(menuExtraHandle, 0);

  // Check if the menuExtra was added successfully.
  return [self getMenuExtra:menuExtraBundle] == nil ? YES : NO;
}

/**
 Adds the menu extra if it is not on the menu bar.

 - parameters:
 - menuExtra: The bundle of the menu extra.

 - returns: A value indicating the success of the operation.
 */

+ (BOOL)addMenuExtra:(NSBundle *)menuExtraBundle atPosition:(int)position {
  if ([self getMenuExtra:menuExtraBundle] != nil)
    return NO;

  CoreMenuExtraAddMenuExtra((__bridge CFURLRef)menuExtraBundle.bundleURL,
                            position, 0, 0, 0, 0);

  // Check if the menuExtra was added successfully.
  return [self getMenuExtra:menuExtraBundle] != nil ? YES : NO;
}

@end
