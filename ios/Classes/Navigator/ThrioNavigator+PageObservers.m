// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

#import <objc/runtime.h>
#import "ThrioNavigator+PageObservers.h"
#import "ThrioLogger.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ThrioNavigator (PageObservers)

+ (ThrioRegistrySet<id<NavigatorPageObserverProtocol>> *)pageObservers {
  id value = objc_getAssociatedObject(self, _cmd);
  if (!value) {
    value = [ThrioRegistrySet set];
    objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return value;
}

+ (void)onCreate:(NavigatorRouteSettings *)routeSettings {
  ThrioLogV(@"%@ %@.%@", NSStringFromSelector(_cmd), routeSettings.url, routeSettings.index);
  ThrioRegistrySet *pageObservers = [self.pageObservers copy];
  for (id<NavigatorPageObserverProtocol> observer in pageObservers) {
    [observer onCreate:routeSettings];
  }
}

+ (void)willAppear:(NavigatorRouteSettings *)routeSettings {
  ThrioLogV(@"%@ %@.%@", NSStringFromSelector(_cmd), routeSettings.url, routeSettings.index);
  ThrioRegistrySet *pageObservers = [self.pageObservers copy];
  for (id<NavigatorPageObserverProtocol> observer in pageObservers) {
    [observer willAppear:routeSettings];
  }
}

+ (void)didAppear:(NavigatorRouteSettings *)routeSettings {
  ThrioLogV(@"%@ %@.%@", NSStringFromSelector(_cmd), routeSettings.url, routeSettings.index);
  ThrioRegistrySet *pageObservers = [self.pageObservers copy];
  for (id<NavigatorPageObserverProtocol> observer in pageObservers) {
    [observer didAppear:routeSettings];
  }
}

+ (void)willDisappear:(NavigatorRouteSettings *)routeSettings {
  ThrioLogV(@"%@ %@.%@", NSStringFromSelector(_cmd), routeSettings.url, routeSettings.index);
  ThrioRegistrySet *pageObservers = [self.pageObservers copy];
  for (id<NavigatorPageObserverProtocol> observer in pageObservers) {
    [observer willDisappear:routeSettings];
  }
}

+ (void)didDisappear:(NavigatorRouteSettings *)routeSettings {
  ThrioLogV(@"%@ %@.%@", NSStringFromSelector(_cmd), routeSettings.url, routeSettings.index);
  ThrioRegistrySet *pageObservers = [self.pageObservers copy];
  for (id<NavigatorPageObserverProtocol> observer in pageObservers) {
    [observer didDisappear:routeSettings];
  }
}

@end

NS_ASSUME_NONNULL_END
