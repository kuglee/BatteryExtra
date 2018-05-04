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
import os.log

var pluginMainBundle: Bundle!
fileprivate var log: OSLog!

@objc class SIMBLPlugin: NSObject {
  class func reloadMenuExtraIfVisibleOnMenuBar(bundlePath menuExtraBundlePath: String) {
    let connectionToReioadHeiperService = NSXPCConnection(serviceName: "com.kuglee.batteryextra.reloadhelper")
    connectionToReioadHeiperService.remoteObjectInterface = NSXPCInterface(with: ReloadHelperProtocol.self)
    connectionToReioadHeiperService.resume()

    let reioadHelperService = (connectionToReioadHeiperService.remoteObjectProxy as AnyObject).remoteObjectProxyWithErrorHandler {
      error in
      os_log("Could not connect to \"reloadhelper\" service! %{public}@.", log: log, type: .error, error as CVarArg)
    } as! ReloadHelperProtocol

    reioadHelperService.getMenuExtra(bundlePath: menuExtraBundlePath, reply: { (success) -> Void in
      if success {
        os_log("Reloading Menu Extra...", log: log)
        reioadHelperService.reloadMenuExtra(bundlePath: menuExtraBundlePath, reply: { (success) -> Void in
          if success {
            os_log("The Menu Extra \"%{public}@ \" was reloaded successfully!", log: log, menuExtraBundlePath)
          } else {
            os_log("Could not reload Menu Extra \"%{public}@\"!", log: log, type: .error, menuExtraBundlePath)
          }

          connectionToReioadHeiperService.invalidate()
        })
      } else {
        connectionToReioadHeiperService.invalidate()
      }
    })
  }

  class func loadMenuExtraBundleIfNotLoaded(path menuExtraBundlePath: String) -> Bool {
    let isMenuExtraLoaded = Bundle.allBundles.contains { (bundle) -> Bool in
      bundle.bundlePath == menuExtraBundlePath
    }

    // Load the Menu Extra manually if it's not already loaded to be able to swizzle it.
    if !isMenuExtraLoaded {
      if let menuExtraBundle = Bundle(path: menuExtraBundlePath) {
        return menuExtraBundle.load()
      }

      return false
    }

    return true
  }

  class func swizzle() throws {
    if let BatteryExtraClass = NSClassFromString("BatteryExtra") {
      try swizzleInstanceMethodObjcString(of: BatteryExtraClass,
                                          from: #selector(BatteryExtra.swizzled_statusMenuItemTitleWithSourceState),
                                          to: "_statusMenuItemTitleWithSourceState:")

      try swizzleInstanceMethodObjcString(of: BatteryExtraClass,
                                          from: #selector(BatteryExtra.swizzled_menuBarStringWithSourceState(_:)),
                                          to: "_menuBarStringWithSourceState:")

      try swizzleInstanceMethodObjcString(of: BatteryExtraClass,
                                          from: #selector(BatteryExtra.swizzledDelayedInitBatteryMenu),
                                          to: "delayedInitBatteryMenu")

      try swizzleInstanceMethodObjcString(of: BatteryExtraClass,
                                          from: #selector(BatteryExtra.swizzledCreateMenu),
                                          to: "createMenu")

      try swizzleInstanceMethodObjcString(of: BatteryExtraClass,
                                          from: #selector(BatteryExtra.swizzledSelectShowMenuItem(_:)),
                                          to: "selectShowMenuItem:")

      try swizzleInstanceMethodObjcString(of: BatteryExtraClass,
                                          from: #selector(BatteryExtra.swizzledValidateMenuItem(_:)),
                                          to: "validateMenuItem:")

      try swizzleInstanceMethodObjcString(of: BatteryExtraClass,
                                          from: #selector(BatteryExtra.swizzledUpdateMenu),
                                          to: "updateMenu")

      try swizzleInstanceMethodObjcString(of: BatteryExtraClass,
                                          from: #selector(BatteryExtra.swizzled_timeStringForMinutes(_:)),
                                          to: "_timeStringForMinutes:")
    } else {
      throw SwizzleError.classNotFound(errorMessage: "Swizzled class \"BatteryExtra\" could not be found!")
    }

    if let BatteryViewInMenuClass = NSClassFromString("BatteryViewInMenu") {
      try swizzleInstanceMethodObjcString(of: BatteryViewInMenuClass,
                                          from: #selector(BatteryViewInMenu.swizzledUpdateInfo),
                                          to: "updateInfo")
    } else {
      throw SwizzleError.classNotFound(errorMessage: "Swizzled class \"BatteryViewInMenu\" could not be found!")
    }
  }

  @objc class func initializePlugin() {
    pluginMainBundle = Bundle(for: self)
    log = OSLog(subsystem: pluginMainBundle.bundleIdentifier!, category: "SIMBLPlugin")

    os_log("Swizzling \"%@\"...", log: log, Bundle.main.bundleIdentifier!)

    // The bundle path of the Menu Extra is stored in the Info.plist of the plugin.
    guard let menuExtraBundlePath = pluginMainBundle.object(forInfoDictionaryKey: "NSMenuExtraBundlePath") as? String else {
      os_log("Couldn't find the value of \"NSMenuExtraBundlePath\" in the Info.plist file. Quitting...", type: .error)
      return
    }

    let menuExtraDidLoad = loadMenuExtraBundleIfNotLoaded(path: menuExtraBundlePath)

    if !menuExtraDidLoad {
      os_log("Could not load bundle \"%{public}@\"! Quitting...", log: log, type: .error, menuExtraBundlePath)
      return
    }

    DispatchQueue.main.async {
      do {
        try swizzle()
      } catch {
        switch error {
        case let SwizzleError.classNotFound(errorMessage):
          os_log("%{public}@", log: log, type: .error, errorMessage)
        case let SwizzleError.methodNotFound(errorMessage):
          os_log("%{public}@", log: log, type: .error, errorMessage)
        default:
          os_log("Unexpected error: %{public}@", log: log, type: .error, error as CVarArg)
        }

        os_log("Could not swizzle \"%@\"!", log: log, type: .error, Bundle.main.bundleIdentifier!)
        return
      }

      os_log("\"%@\" was swizzled successfully!", log: log, Bundle.main.bundleIdentifier!)

      reloadMenuExtraIfVisibleOnMenuBar(bundlePath: menuExtraBundlePath)
    }
  }
}
