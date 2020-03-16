//
//  ThrioNavigator+Observer.m
//  thrio
//
//  Created by fox softer on 2020/3/14.
//

#import <objc/runtime.h>
#import "ThrioNavigator+PageObserver.h"
#import "ThrioLogger.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ThrioNavigator (PageObserver)

+ (ThrioRegistrySet<id<NavigatorPageObserverProtocol>> *)pageObservers {
  id value = objc_getAssociatedObject(self, _cmd);
  if (!value) {
    value = [ThrioRegistrySet set];
    objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return value;
}

+ (void)onCreate:(NavigatorRouteSettings *)routeSettings {
  ThrioLogV(@"%@ %@", NSStringFromSelector(_cmd), routeSettings);
  ThrioRegistrySet *pageObservers = [self.pageObservers copy];
  for (id<NavigatorPageObserverProtocol> observer in pageObservers) {
    [observer onCreate:routeSettings];
  }
}

+ (void)willAppear:(NavigatorRouteSettings *)routeSettings {
  ThrioLogV(@"%@ %@", NSStringFromSelector(_cmd), routeSettings);
  ThrioRegistrySet *pageObservers = [self.pageObservers copy];
  for (id<NavigatorPageObserverProtocol> observer in pageObservers) {
    [observer willAppear:routeSettings];
  }
}

+ (void)didAppear:(NavigatorRouteSettings *)routeSettings {
  ThrioLogV(@"%@ %@", NSStringFromSelector(_cmd), routeSettings);
  ThrioRegistrySet *pageObservers = [self.pageObservers copy];
  for (id<NavigatorPageObserverProtocol> observer in pageObservers) {
    [observer didAppear:routeSettings];
  }
}

+ (void)willDisappear:(NavigatorRouteSettings *)routeSettings {
  ThrioLogV(@"%@ %@", NSStringFromSelector(_cmd), routeSettings);
  ThrioRegistrySet *pageObservers = [self.pageObservers copy];
  for (id<NavigatorPageObserverProtocol> observer in pageObservers) {
    [observer willDisappear:routeSettings];
  }
}

+ (void)didDisappear:(NavigatorRouteSettings *)routeSettings {
  ThrioLogV(@"%@ %@", NSStringFromSelector(_cmd), routeSettings);
  ThrioRegistrySet *pageObservers = [self.pageObservers copy];
  for (id<NavigatorPageObserverProtocol> observer in pageObservers) {
    [observer didDisappear:routeSettings];
  }
}

@end

NS_ASSUME_NONNULL_END
