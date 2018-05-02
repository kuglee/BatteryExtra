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

int CoreMenuExtraGetMenuExtra(CFStringRef identifier, int *menuExtra);
int CoreMenuExtraAddMenuExtra(CFURLRef path, int position, int arg3, int arg4,
                              int arg5, int arg6);
int CoreMenuExtraRemoveMenuExtra(int menuExtra, int arg2);
