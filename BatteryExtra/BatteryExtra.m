/*
 * Copyright © 2017 Gábor Librecz <kuglee@gmail.com>
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

@implementation NSMenuExtra
@end

@interface MyBatteryExtra : NSMenuExtra <NSMenuDelegate>

- (NSString *)_timeStringForMinutes:(unsigned long long)minutes;

@end

@implementation MyBatteryExtra

BOOL * showPerc;
BOOL showTime;
BOOL hideWhenCharged;
BOOL hideIcon;
NSBundle * myBundle;
NSUserDefaults * defaults;

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

  if (state.allSourcesCharged && hideWhenCharged && !hideIcon) {
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
  defaults =
      [[NSUserDefaults alloc] initWithSuiteName:[myBundle bundleIdentifier]];

  hideWhenCharged = [defaults boolForKey:@"HideWhenCharged"];
  hideIcon = [defaults boolForKey:@"HideIcon"];
  showPerc = &ZKHookIvar(self, BOOL, "_showPerc");
  *showPerc = [defaults boolForKey:@"ShowPercent"];
  showTime = [defaults boolForKey:@"ShowTime"];

  if (showTime && *showPerc) {
    *showPerc = NO;
    [defaults setBool:*showPerc forKey:@"ShowPercent"];
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
  [menu insertItem:showMenuItem atIndex:[[menu itemArray] count] - 1];

  NSMenu *showMenu = [[NSMenu alloc] initWithTitle:@""];
  [menu setSubmenu:showMenu forItem:showMenuItem];

  NSMenuItem *showIconOnlyMenuItem = [[NSMenuItem alloc]
      initWithTitle:[myBundle localizedStringForKey:@"NONE" value:@""
                                              table:nil]
             action:@selector(selectShowMenuItem:)
      keyEquivalent:@""];
  [showIconOnlyMenuItem setTarget:self];
  [showIconOnlyMenuItem setTag:3];
  if (!*showPerc && !showTime)
    [showIconOnlyMenuItem setState:NSOnState];
  [showMenu addItem:showIconOnlyMenuItem];

  NSMenuItem *showTimeMenuItem = [[NSMenuItem alloc]
      initWithTitle:[myBundle localizedStringForKey:@"DISPLAY_TIME"
                                              value:@""
                                              table:nil]
             action:@selector(selectShowMenuItem:)
      keyEquivalent:@""];
  [showTimeMenuItem setTarget:self];
  [showTimeMenuItem setTag:1];
  if (showTime)
    [showTimeMenuItem setState:NSOnState];
  [showMenu addItem:showTimeMenuItem];

  NSMenuItem *showPercentMenuItem =
      ZKHookIvar(self, NSMenuItem *, "_showPercentMenuItem");
  [showPercentMenuItem setTag:2];
  [showPercentMenuItem
      setTitle:[myBundle localizedStringForKey:@"DISPLAY_PERCENT"
                                         value:@""
                                         table:nil]];
  if (*showPerc)
    [showPercentMenuItem setState:NSOnState];
  [menu removeItem:showPercentMenuItem];
  [showMenu addItem:showPercentMenuItem];

  [menu insertItem:[NSMenuItem separatorItem]
           atIndex:[[menu itemArray] count] - 1];

  [self performSelector:@selector(updateMenu)];

  return menu;
}

- (void)selectShowMenuItem:(id)sender {
  switch ([sender tag]) {
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
    break;
  }

  [defaults setBool:showTime forKey:@"ShowTime"];
  [defaults setBool:*showPerc forKey:@"ShowPercent"];

  [self performSelector:@selector(updateMenu)];
}

- (BOOL)validateMenuItem:(NSMenuItem *)item {
  if ([item tag] == 3)
    [item setState:(!showTime && !*showPerc) ? NSOnState : NSOffState];
  else if ([item tag] == 1)
    [item setState:showTime ? NSOnState : NSOffState];
  else if ([item tag] == 2)
    [item setState:*showPerc ? NSOnState : NSOffState];

  return YES;
}

@end
