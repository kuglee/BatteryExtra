/*
 * Copyright (c) Gábor Librecz <kuglee@gmail.com>
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://www.wtfpl.net/ for more details.
 */

import AppKit

typealias BatteryViewInMenu = NSView

extension BatteryViewInMenu {
  @objc func swizzledUpdateInfo() {
    swizzledUpdateInfo()

    // Changes the width of the battery icon in order to hide it.
    if hideIcon {
      setValue(0, forKey: "_batteryRectWidth")
    }
  }
}
