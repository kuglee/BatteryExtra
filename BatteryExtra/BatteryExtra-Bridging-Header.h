/*
 * Copyright (c) Gábor Librecz <kuglee@gmail.com>
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://www.wtfpl.net/ for more details.
 */

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
