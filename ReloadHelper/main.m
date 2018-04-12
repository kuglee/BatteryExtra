/*
 * Copyright (c) 2017 Gábor Librecz <kuglee@gmail.com>
 *
 * This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://www.wtfpl.net/ for more details.
 */

#import <Foundation/Foundation.h>
#import "ReloadHelper.h"

@interface ServiceDelegate : NSObject <NSXPCListenerDelegate>
@end

@implementation ServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener
    shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
  newConnection.exportedInterface =
      [NSXPCInterface interfaceWithProtocol:@protocol(ReloadHelperProtocol)];

  ReloadHelper *exportedObject = [ReloadHelper new];
  newConnection.exportedObject = exportedObject;

  [newConnection resume];

  return YES;
}

@end

int main(int argc, const char *argv[]) {
  ServiceDelegate *delegate = [ServiceDelegate new];

  NSXPCListener *listener = [NSXPCListener serviceListener];
  listener.delegate = delegate;

  [listener resume];
}
