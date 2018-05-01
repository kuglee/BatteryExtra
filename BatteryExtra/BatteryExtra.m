/*
 * Copyright (c) Gábor Librecz <kuglee@gmail.com>
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://www.wtfpl.net/ for more details.
 */

#import "ZKSwizzle.h"
#import <AppKit/AppKit.h>

struct powerSourceTypeStruct {
  long long numberOfSources;
  long long numberOfSourcesPresent;
  long long totalNumberOfMinutesLeft;
  long long totalCurrentCapacity;
  long long totalMaxCapacity;
  char isPresent;
  char anySourceCalculating;
  char anySourceUnknownMinutesLeft;
  char lastSourceIsFinishingCharge;
  char anySourceIsPluggedIn;
  char anySourceCharging;
  char allSourcesCharged;
  char anySourceInPoorCondition;
  char anySourceInCheckBatteryCondition;
  char anySourceInFairCondition;
  char anySourceInUnknownCondition;
  double percentageRemaining;
};

@interface NSMenuExtra : NSStatusItem
@end

/// Readds code removed by Apple.
@implementation NSMenuExtra
@end

@interface MyBatteryExtra : NSMenuExtra <NSMenuDelegate>

- (NSString *)_timeStringForMinutes:(unsigned long long)minutes;

@end

@implementation MyBatteryExtra

BOOL *showPerc;
BOOL showTime;
BOOL hideLabelWhenCharged;
BOOL hideIcon;
NSBundle *myBundle;
NSUserDefaults *userDefaults;
extern NSBundle *pluginMainBundle;

- (NSString *)_statusMenuItemTitleWithSourceState:
    (struct powerSourceTypeStruct)state {
  NSString *title = ZKOrig(id, state);

  if (showTime) {
    if (state.allSourcesCharged) {
      if (state.numberOfSourcesPresent == 1)
        title =
            [myBundle localizedStringForKey:@"BAT_CHARGED" value:@""
                                      table:nil];
      else
        title = [myBundle localizedStringForKey:@"BATS_CHARGED"
                                          value:@""
                                          table:nil];
    } else {
      if (state.anySourceIsPluggedIn && !state.anySourceCharging) {
        if (state.numberOfSourcesPresent == 1)
          title = [myBundle localizedStringForKey:@"BAT_NOT_CHARGING"
                                            value:@""
                                            table:nil];
        else
          title = [myBundle localizedStringForKey:@"BATS_NOT_CHARGING"
                                            value:@""
                                            table:nil];
      } else {
        NSString *percentageString = [NSNumberFormatter
            localizedStringFromNumber:
                [NSNumber numberWithFloat:state.percentageRemaining / 100]
                          numberStyle:3];
        NSString *localizedPercentageStringFormat =
            [myBundle localizedStringForKey:@"SINGLE_PERCENT_FORMAT"
                                      value:@""
                                      table:nil];
        NSString *localizedPercentageString =
            [NSString localizedStringWithFormat:localizedPercentageStringFormat,
                                                percentageString];

        if (state.lastSourceIsFinishingCharge) {
          NSString *localizedString =
              [myBundle localizedStringForKey:@"BAT_FINISH_PERC"
                                        value:@""
                                        table:nil];
          title =
              [NSString localizedStringWithFormat:localizedString,
                                                  localizedPercentageString];
        } else {
          NSString *localizedString =
              [myBundle localizedStringForKey:@"PERCENT_FULL"
                                        value:@""
                                        table:nil];
          title =
              [NSString localizedStringWithFormat:localizedString,
                                                  localizedPercentageString];
        }
      }
    }
  } else {
    if (state.allSourcesCharged) {
      if (state.numberOfSourcesPresent == 1)
        title =
            [myBundle localizedStringForKey:@"BAT_CHARGED" value:@""
                                      table:nil];
      else
        title = [myBundle localizedStringForKey:@"BATS_CHARGED"
                                          value:@""
                                          table:nil];
    } else if (state.anySourceCalculating) {
      if (state.anySourceIsPluggedIn)
        title = [myBundle localizedStringForKey:@"CALCULATING_TIME_UNTIL_FULL"
                                          value:@""
                                          table:nil];
      else
        title = [myBundle localizedStringForKey:@"CALCULATING_TIME_REMAINING"
                                          value:@""
                                          table:nil];
    } else if (state.anySourceCharging) {
      NSString *timeStringForMinutes =
          [self _timeStringForMinutes:state.totalNumberOfMinutesLeft];

      if (state.lastSourceIsFinishingCharge)
        title = [NSString localizedStringWithFormat:
                              [myBundle localizedStringForKey:@"BAT_FINISH_TIME"
                                                        value:@""
                                                        table:nil],
                              timeStringForMinutes];
      else {
        if (state.totalNumberOfMinutesLeft > 600)
          title = [NSString
              localizedStringWithFormat:
                  [myBundle localizedStringForKey:@"TIME_UNTIL_FULL_TOO_LONG"
                                            value:@""
                                            table:nil],
                  timeStringForMinutes];
        else
          title =
              [NSString localizedStringWithFormat:
                            [myBundle localizedStringForKey:@"TIME_UNTIL_FULL"
                                                      value:@""
                                                      table:nil],
                            timeStringForMinutes];
      }
    } else if (state.anySourceIsPluggedIn) {
      if (state.numberOfSourcesPresent == 1)
        title = [myBundle localizedStringForKey:@"BAT_NOT_CHARGING"
                                          value:@""
                                          table:nil];
      else
        title = [myBundle localizedStringForKey:@"BATS_NOT_CHARGING"
                                          value:@""
                                          table:nil];

    } else {
      NSString *timeStringForMinutes =
          [self _timeStringForMinutes:state.totalNumberOfMinutesLeft];
      title = [NSString
          localizedStringWithFormat:[myBundle
                                        localizedStringForKey:@"TIME_REMAINING"
                                                        value:@""
                                                        table:nil],
                                    timeStringForMinutes];
    }
  }

  return title;
}

- (NSString *)_menuBarStringWithSourceState:
    (struct powerSourceTypeStruct)state {
  NSString *title = ZKOrig(NSString *, state);

  if (state.allSourcesCharged && hideLabelWhenCharged && !hideIcon) {
    title = nil;
  } else if (showTime && state.numberOfSourcesPresent > 0) {
    if (state.allSourcesCharged) {
      title = [myBundle localizedStringForKey:@"CHARGED" value:@"" table:nil];
    } else if (state.anySourceCalculating)
      title =
          [myBundle localizedStringForKey:@"CALCULATING" value:@"" table:nil];
    else if (state.lastSourceIsFinishingCharge)
      title = [myBundle localizedStringForKey:@"BAT_FINISHING_CHARGE_MENU_BAR"
                                        value:@""
                                        table:nil];
    else if (state.anySourceIsPluggedIn && !state.anySourceCharging)
      title = [myBundle localizedStringForKey:@"BAT_NOT_CHARGING_MENU_BAR"
                                        value:@""
                                        table:nil];
    else if (state.anySourceUnknownMinutesLeft)
      title =
          [myBundle localizedStringForKey:@"UNKNOWN_TIME" value:@"" table:nil];
    else if (state.totalNumberOfMinutesLeft >= 0)
      title = [self _timeStringForMinutes:state.totalNumberOfMinutesLeft];
  }

  return title;
}

- (void)delayedInitBatteryMenu {
  myBundle = ZKHookIvar(self, NSBundle *, "_mybundle");
  userDefaults =
      [[NSUserDefaults alloc] initWithSuiteName:myBundle.bundleIdentifier];

  hideLabelWhenCharged = [userDefaults boolForKey:@"HideLabelWhenCharged"];
  hideIcon = [userDefaults boolForKey:@"HideIcon"];
  showPerc = &ZKHookIvar(self, BOOL, "_showPerc");
  *showPerc = [userDefaults boolForKey:@"ShowPercent"];
  showTime = [userDefaults boolForKey:@"ShowTime"];

  if (showTime && *showPerc) {
    *showPerc = NO;
    [userDefaults setBool:*showPerc forKey:@"ShowPercent"];
  }

  ZKOrig(void);
}

- (NSMenu *)createMenu {
  NSMenu *menu = ZKOrig(NSMenu *);

  NSMenuItem *showMenuItem = [[NSMenuItem alloc]
      initWithTitle:[myBundle localizedStringForKey:@"SHOW" value:@""
                                              table:nil]
             action:nil
      keyEquivalent:@""];
  [menu insertItem:showMenuItem atIndex:menu.itemArray.count - 1];

  NSMenu *showMenu = [[NSMenu alloc] initWithTitle:@""];
  [menu setSubmenu:showMenu forItem:showMenuItem];

  NSMenuItem *showIconOnlyMenuItem = [[NSMenuItem alloc]
      initWithTitle:[myBundle localizedStringForKey:@"NONE" value:@""
                                              table:nil]
             action:@selector(selectShowMenuItem:)
      keyEquivalent:@""];
  showIconOnlyMenuItem.target = self;
  showIconOnlyMenuItem.tag = 3;
  if (!*showPerc && !showTime)
    showIconOnlyMenuItem.state = NSOnState;
  [showMenu addItem:showIconOnlyMenuItem];

  NSMenuItem *showTimeMenuItem = [[NSMenuItem alloc]
      initWithTitle:[myBundle localizedStringForKey:@"DISPLAY_TIME"
                                              value:@""
                                              table:nil]
             action:@selector(selectShowMenuItem:)
      keyEquivalent:@""];
  showTimeMenuItem.target = self;
  showTimeMenuItem.tag = 1;
  if (showTime)
    showTimeMenuItem.state = NSOnState;
  [showMenu addItem:showTimeMenuItem];

  NSMenuItem *showPercentMenuItem =
      ZKHookIvar(self, NSMenuItem *, "_showPercentMenuItem");
  showPercentMenuItem.tag = 2;
  showPercentMenuItem.title =
      [myBundle localizedStringForKey:@"DISPLAY_PERCENT" value:@"" table:nil];
  if (*showPerc)
    showPercentMenuItem.state = NSOnState;
  [menu removeItem:showPercentMenuItem];
  [showMenu addItem:showPercentMenuItem];

  [showMenu addItem:NSMenuItem.separatorItem];

  NSMenuItem *showIcon = [[NSMenuItem alloc]
      initWithTitle:[pluginMainBundle localizedStringForKey:@"SHOW_ICON"
                                                      value:@""
                                                      table:nil]
             action:@selector(selectShowMenuItem:)
      keyEquivalent:@""];
  showIcon.target = self;
  showIcon.tag = 4;

  showIconOnlyMenuItem.state = NSOnState;
  [showMenu addItem:showIcon];

  [menu insertItem:NSMenuItem.separatorItem atIndex:menu.itemArray.count - 1];

  [self performSelector:@selector(updateMenu)];

  return menu;
}

- (void)selectShowMenuItem:(NSMenuItem *)sender {
  switch (sender.tag) {
  case 1:
    showTime = YES;
    *showPerc = NO;
    break;
  case 2:
    showTime = NO;
    *showPerc = YES;
    break;
  case 3:
    showTime = NO;
    *showPerc = NO;
    hideIcon = NO;
    break;
  case 4:
    if (!showTime && !*showPerc)
      *showPerc = YES;

    hideIcon = !hideIcon;
    break;
  }

  [userDefaults setBool:showTime forKey:@"ShowTime"];
  [userDefaults setBool:*showPerc forKey:@"ShowPercent"];
  [userDefaults setBool:hideIcon forKey:@"HideIcon"];

  [self performSelector:@selector(updateMenu)];
}

- (BOOL)validateMenuItem:(NSMenuItem *)item {
  switch (item.tag) {
  case 1:
    item.state = showTime ? NSOnState : NSOffState;
    break;
  case 2:
    item.state = *showPerc ? NSOnState : NSOffState;
    break;
  case 3:
    item.state =
        (!showTime && !*showPerc && !hideIcon) ? NSOnState : NSOffState;
    break;
  case 4:
    item.state = !hideIcon;
    break;
  default:
    break;
  }

  return YES;
}

@end
