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

fileprivate var showTime: Bool!
fileprivate var hideLabelWhenCharged: Bool!
var hideIcon: Bool!
var userDefaults: UserDefaults!

typealias BatteryExtra = NSStatusItem

/// Readds code removed by Apple.
extension BatteryExtra {
  var showPercent: Bool {
    get {
      return value(forKey: "_showPerc") as! Bool
    }
    set {
      setValue(newValue, forKey: "_showPerc")
    }
  }

  var mybundle: Bundle {
    get {
      return value(forKey: "_mybundle") as! Bundle
    }
    set {
      setValue(newValue, forKey: "_mybundle")
    }
  }

  @objc func swizzled_timeStringForMinutes(_ minutes: CUnsignedLongLong) -> NSString {
    return swizzled_timeStringForMinutes(minutes)
  }

  @objc func swizzledUpdateMenu() {
    swizzledUpdateMenu()
  }

  @objc func swizzled_statusMenuItemTitleWithSourceState(_ sourceState: powerSourceTypeStruct) -> NSString {
    var title = swizzled_statusMenuItemTitleWithSourceState(sourceState) as String

    if showTime {
      if sourceState.allSourcesCharged > 0 {
        if sourceState.numberOfSourcesPresent == 1 {
          title = mybundle.localizedString(forKey: "BAT_CHARGED", value: "", table: nil)
        } else {
          title = mybundle.localizedString(forKey: "BATS_CHARGED", value: "", table: nil)
        }
      } else {
        if sourceState.anySourceIsPluggedIn > 0, !(sourceState.anySourceCharging > 0) {
          if sourceState.numberOfSourcesPresent == 1 {
            title = mybundle.localizedString(forKey: "BAT_NOT_CHARGING", value: "", table: nil)
          } else {
            title = mybundle.localizedString(forKey: "BATS_NOT_CHARGING", value: "", table: nil)
          }
        } else {
          let percentageString = NumberFormatter.localizedString(from: NSNumber(floatLiteral: sourceState.percentageRemaining / 100), number: NumberFormatter.Style.percent)

          let localizedPercentageStringFormat = mybundle.localizedString(forKey: "SINGLE_PERCENT_FORMAT", value: "", table: nil)

          let localizedPercentageString = String.localizedStringWithFormat(localizedPercentageStringFormat, percentageString)

          if sourceState.lastSourceIsFinishingCharge > 0 {
            let localizedString = mybundle.localizedString(forKey: "BAT_FINISH_PERC", value: "", table: nil)
            title = String.localizedStringWithFormat(localizedString, localizedPercentageString)
          } else {
            let localizedString = mybundle.localizedString(forKey: "PERCENT_FULL", value: "", table: nil)
            title = String.localizedStringWithFormat(localizedString, localizedPercentageString)
          }
        }
      }
    } else {
      if sourceState.allSourcesCharged > 0 {
        if sourceState.numberOfSourcesPresent == 1 {
          title = mybundle.localizedString(forKey: "BAT_CHARGED", value: "", table: nil)
        } else {
          title = mybundle.localizedString(forKey: "BATS_CHARGED", value: "", table: nil)
        }
      } else if sourceState.anySourceCalculating > 0 {
        if sourceState.anySourceIsPluggedIn > 0 {
          title = mybundle.localizedString(forKey: "CALCULATING_TIME_UNTIL_FULL", value: "", table: nil)
        } else {
          title = mybundle.localizedString(forKey: "CALCULATING_TIME_REMAINING", value: "", table: nil)
        }
      } else if sourceState.anySourceCharging > 0 {
        let timeStringForMinutes = swizzled_timeStringForMinutes(CUnsignedLongLong(sourceState.totalNumberOfMinutesLeft))

        if sourceState.lastSourceIsFinishingCharge > 0 {
          title = String.localizedStringWithFormat(mybundle.localizedString(forKey: "BAT_FINISH_TIME", value: "", table: nil), timeStringForMinutes)
        } else {
          if sourceState.totalNumberOfMinutesLeft > 600 {
            title = String.localizedStringWithFormat(mybundle.localizedString(forKey: "TIME_UNTIL_FULL_TOO_LONG", value: "", table: nil), timeStringForMinutes)
          } else {
            title = String.localizedStringWithFormat(mybundle.localizedString(forKey: "TIME_UNTIL_FULL", value: "", table: nil), timeStringForMinutes)
          }
        }
      } else if sourceState.anySourceIsPluggedIn > 0 {
        if sourceState.numberOfSourcesPresent == 1 {
          title = mybundle.localizedString(forKey: "BAT_NOT_CHARGING", value: "", table: nil)
        } else {
          title = mybundle.localizedString(forKey: "BATS_NOT_CHARGING", value: "", table: nil)
        }
      } else {
        let timeStringForMinutes = swizzled_timeStringForMinutes(CUnsignedLongLong(sourceState.totalNumberOfMinutesLeft))
        title = String.localizedStringWithFormat(mybundle.localizedString(forKey: "TIME_REMAINING", value: "", table: nil), timeStringForMinutes)
      }
    }

    return title as NSString
  }

  @objc func swizzled_menuBarStringWithSourceState(_ sourceState: powerSourceTypeStruct) -> NSString {
    var title = swizzled_menuBarStringWithSourceState(sourceState) as String

    if sourceState.allSourcesCharged > 0, hideLabelWhenCharged, !hideIcon {
      title = ""
    } else
    if showTime, sourceState.numberOfSourcesPresent > 0 {
      if sourceState.allSourcesCharged > 0 {
        title = mybundle.localizedString(forKey: "CHARGED", value: "", table: nil)
      } else if sourceState.anySourceCalculating > 0 {
        title = mybundle.localizedString(forKey: "CALCULATING", value: "", table: nil)
      } else if sourceState.lastSourceIsFinishingCharge > 0 {
        title = mybundle.localizedString(forKey: "BAT_FINISHING_CHARGE_MENU_BAR", value: "", table: nil)
      } else if sourceState.anySourceIsPluggedIn > 0, !(sourceState.anySourceCharging > 0) {
        title = mybundle.localizedString(forKey: "BAT_NOT_CHARGING_MENU_BAR", value: "", table: nil)
      } else if sourceState.anySourceUnknownMinutesLeft > 0 {
        title = mybundle.localizedString(forKey: "UNKNOWN_TIME", value: "", table: nil)
      } else if sourceState.totalNumberOfMinutesLeft >= 0 {
        title = swizzled_timeStringForMinutes(CUnsignedLongLong(sourceState.totalNumberOfMinutesLeft)) as String
      }
    }

    return title as NSString
  }

  @objc func swizzledDelayedInitBatteryMenu() {
    userDefaults = UserDefaults(suiteName: mybundle.bundleIdentifier)!

    hideLabelWhenCharged = userDefaults.bool(forKey: "HideLabelWhenCharged")
    hideIcon = userDefaults.bool(forKey: "HideIcon")
    showPercent = userDefaults.bool(forKey: "ShowPercent")
    showTime = userDefaults.bool(forKey: "ShowTime")
    hideIcon = userDefaults.bool(forKey: "HideIcon")

    if showTime, showPercent {
      showPercent = false
      userDefaults.set(showPercent, forKey: "ShowPercent")
    }

    swizzledDelayedInitBatteryMenu()
  }

  @objc func swizzledCreateMenu() -> NSMenu {
    let menu = swizzledCreateMenu()

    let showMenuItem = NSMenuItem(title: mybundle.localizedString(forKey: "SHOW", value: "", table: nil), action: nil, keyEquivalent: "")
    menu.insertItem(showMenuItem, at: menu.items.count - 1)

    let showMenu = NSMenu(title: "")
    menu.setSubmenu(showMenu, for: showMenuItem)

    let showIconOnlyMenuItem = NSMenuItem(title: mybundle.localizedString(forKey: "NONE", value: "", table: nil), action: NSSelectorFromString("selectShowMenuItem:"), keyEquivalent: "")
    showIconOnlyMenuItem.target = self
    showIconOnlyMenuItem.tag = 3
    if !showPercent, !showTime {
      showIconOnlyMenuItem.state = NSControl.StateValue.on
    }
    showMenu.addItem(showIconOnlyMenuItem)

    let showTimeMenuItem = NSMenuItem(title: mybundle.localizedString(forKey: "DISPLAY_TIME", value: "", table: nil), action: NSSelectorFromString("selectShowMenuItem:"), keyEquivalent: "")
    showTimeMenuItem.target = self
    showTimeMenuItem.tag = 1
    if showTime {
      showTimeMenuItem.state = NSControl.StateValue.on
    }
    showMenu.addItem(showTimeMenuItem)

    let showPercentMenuItem = value(forKey: "_showPercentMenuItem") as! NSMenuItem
    showPercentMenuItem.title = mybundle.localizedString(forKey: "DISPLAY_PERCENT", value: "", table: nil)
    showPercentMenuItem.tag = 2
    if showPercent {
      showPercentMenuItem.state = NSControl.StateValue.on
    }

    menu.removeItem(showPercentMenuItem)
    showMenu.addItem(showPercentMenuItem)

    showMenu.addItem(NSMenuItem.separator())

    let showIcon = NSMenuItem(title: pluginMainBundle.localizedString(forKey: "SHOW_ICON", value: "", table: nil), action: NSSelectorFromString("selectShowMenuItem:"), keyEquivalent: "")
    showIcon.target = self
    showIcon.tag = 4
    showIcon.state = NSControl.StateValue.on
    showMenu.addItem(showIcon)

    menu.insertItem(NSMenuItem.separator(), at: menu.items.count - 1)

    swizzledUpdateMenu()

    return menu
  }

  @objc func swizzledSelectShowMenuItem(_ menuItem: NSMenuItem) {
    switch menuItem.tag {
    case 1:
      showTime = true
      showPercent = false
    case 2:
      showTime = false
      showPercent = true
    case 3:
      showTime = false
      showPercent = false
      hideIcon = false
    case 4:
      if !showTime, !showPercent {
        showPercent = true
      }

      hideIcon = !hideIcon
    default:
      break
    }

    userDefaults.set(showTime, forKey: "ShowTime")
    userDefaults.set(showPercent, forKey: "ShowPercent")
    userDefaults.set(hideIcon, forKey: "HideIcon")

    swizzledUpdateMenu()
  }

  @objc func swizzledValidateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    switch menuItem.tag {
    case 1:
      menuItem.state = showTime ? NSControl.StateValue.on : NSControl.StateValue.off
    case 2:
      menuItem.state = showPercent ? NSControl.StateValue.on : NSControl.StateValue.off
    case 3:
      menuItem.state = (!showTime && !showPercent && !hideIcon) ? NSControl.StateValue.on : NSControl.StateValue.off
    case 4:
      menuItem.state = !hideIcon ? NSControl.StateValue.on : NSControl.StateValue.off
    default:
      break
    }

    return true
  }
}
