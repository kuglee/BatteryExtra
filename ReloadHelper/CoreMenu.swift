/*
 * Copyright (c) Gábor Librecz <kuglee@gmail.com>
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://www.wtfpl.net/ for more details.
 */

import Foundation

/// A wrapper class of CoreMenu functions for managing menu extras. (From "ApplicationServices/HIServices" framework)
class CoreMenu {
  typealias MenuExtraHandle = CInt
  
  /**
    Returns a handle for the menu extra if it is on the menu bar.
   
    - parameters:
      - menuExtra: The bundle of the menu extra.
   
    - returns: An optional handle for the menu extra.
  */
  class func get(menuExtra menuExtraBundle: Bundle) -> MenuExtraHandle? {
    var menuExtraHandle: MenuExtraHandle = 0
    
    CoreMenuExtraGetMenuExtra(menuExtraBundle.bundleIdentifier! as CFString, &menuExtraHandle)
    
    return menuExtraHandle != 0 ? menuExtraHandle : nil
  }
  
  /**
    Removes the menu extra if it is on the menu bar.
   
    - parameters:
      - menuExtra: The bundle of the menu extra.
   
    - returns: A value indicating the success of the operation.
  */
  class func remove(menuExtra menuExtraBundle: Bundle) -> Bool {
    guard let menuExtraHandle = get(menuExtra: menuExtraBundle) else {
      return false
    }
    
    CoreMenuExtraRemoveMenuExtra(menuExtraHandle, 0)
    
    // Check if the menuExtra was added successfully.
    return get(menuExtra: menuExtraBundle) == nil ? true : false
  }
  
  /**
    Adds the menu extra if it is not on the menu bar.
   
    - parameters:
      - menuExtra: The bundle of the menu extra.
   
    - returns: A value indicating the success of the operation.
  */
  class func add(menuExtra menuExtraBundle: Bundle, at position: Int) -> Bool {
    if get(menuExtra: menuExtraBundle) != nil {
      return false
    }
    
    CoreMenuExtraAddMenuExtra(menuExtraBundle.bundleURL as CFURL, CInt(position), 0, 0, 0, 0)
    
    // Check if the menuExtra was added successfully.
    return get(menuExtra: menuExtraBundle) != nil ? true : false
  }
}
