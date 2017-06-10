# BatteryExtra
SIMBL plugin for the Battery status indicator.

It makes the Battery status indicator work just like how it did back in Mac OS X Lion (10.7).
It only supports macOS Sierra (10.12).

Screenshots:

  - Show time:

![Show time](https://raw.githubusercontent.com/kuglee/BatteryExtra/master/Screenshots/show_time.png)

  - Show percentage:

![Show percentage](https://raw.githubusercontent.com/kuglee/BatteryExtra/master/Screenshots/show_percentage.png)

  - Show icon only:

![Show icon only](https://raw.githubusercontent.com/kuglee/BatteryExtra/master/Screenshots/show_icon_only.png)

# How to install
  1. Install [mySIMBL](https://github.com/w0lfschild/mySIMBL).
  2. Build from source or download the [latest version](https://github.com/kuglee/BatteryExtra/releases/latest).
  3. Open **BatteryExtra.bundle** with **mySIMBL**.
  4. Log out then log back in or run `killall -KILL SystemUIServer` from the command line.

# Preferences

To only show the battery icon without the label when fully charged, run the following command in the command line:

```bash
defaults write com.apple.menuextra.battery.plist HideWhenCharged YES
```

To change it back run the following command in the command line:

```bash
defaults write com.apple.menuextra.battery.plist HideWhenCharged NO
```
---
To only show the label without the battery run the following command in the command line:

```bash
defaults write com.apple.menuextra.battery.plist HideIcon YES
```

To change it back run the following command in the command line:

```bash
defaults write com.apple.menuextra.battery.plist HideIcon NO
```

You need to log out then log back in for the changes to take effect.
