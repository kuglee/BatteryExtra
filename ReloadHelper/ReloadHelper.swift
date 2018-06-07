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

fileprivate func getDefaultPositionOnMenuBar(of menuExtraBundle: Bundle) -> Int? {
  // The default positions of the built-in Menu Extras are stored in the Extras.plist of the SystemUiServer app.
  let systemUIServerBundle = Bundle(path: "/System/Library/CoreServices/SystemUIServer.app")!
  let extrasPlistURL = systemUIServerBundle.url(forResource: "Extras.plist", withExtension: nil)!
  
  if let extrasArray = NSArray(contentsOf: extrasPlistURL) as? Array<Dictionary<String, Any>> {
    for extraDict in extrasArray {
      if let path = extraDict["path"] as? String, path == menuExtraBundle.bundlePath {
        // The "id" of the menu extra is used as the position.
        if let position = extraDict["id"] as? Int {
          return position
        }
      }
    }
  }
  
  return nil
}

@objc class ReloadHelper: NSObject, ReloadHelperProtocol {
  func getMenuExtra(bundlePath: String, reply: @escaping (Bool) -> Void) {
    let menuExtraBundle = Bundle(path: bundlePath)!
    
    if CoreMenu.get(menuExtra: menuExtraBundle) == nil {
      reply(false)
      return
    }
    
    reply(true)
  }
  
  func reloadMenuExtra(bundlePath: String, reply: @escaping (Bool) -> Void) {
    let menuExtraBundle = Bundle(path: bundlePath)!
    
    guard let position = getDefaultPositionOnMenuBar(of: menuExtraBundle) else {
      reply(false)
      return
    }
    
    // Battery menu extra has to be reloaded twice to function properly.
    // See rdar://32445578 for more information.
    var success = CoreMenu.remove(menuExtra: menuExtraBundle)
      && CoreMenu.add(menuExtra: menuExtraBundle, at: position)
      && CoreMenu.remove(menuExtra: menuExtraBundle)
    
    if success {
      // Sleep is needed because if the Battery menu is added too fast it won't function properly.
      // See rdar://32445578 for more information.
      Thread.sleep(forTimeInterval: 1)
      success = CoreMenu.add(menuExtra: menuExtraBundle, at: position)
    }
    
    reply(success)
  }
}
