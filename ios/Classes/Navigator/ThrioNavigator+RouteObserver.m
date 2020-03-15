//
//  ThrioNavigator+RouteObserver.m
//  thrio
//
//  Created by fox softer on 2020/3/15.
//

#import <objc/runtime.h>
#import "ThrioNavigator+RouteObserver.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ThrioNavigator (RouteObserver)

+ (ThrioRegistrySet<id<NavigatorRouteObserverProtocol>> *)routeObservers {
  id value = objc_getAssociatedObject(self, _cmd);
  if (!value) {
    value = [ThrioRegistrySet set];
    objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return value;
}

+ (void)didPush:(NavigatorRouteSettings *)routeSettings
  previousRoute:(NavigatorRouteSettings * _Nullable)previousRouteSettings {
  ThrioRegistrySet *routeObservers = [self.routeObservers copy];
  for (id<NavigatorRouteObserverProtocol> observer in routeObservers) {
    [observer didPush:routeSettings previousRoute:previousRouteSettings];
  }
}

+ (void)didPop:(NavigatorRouteSettings *)routeSettings
 previousRoute:(NavigatorRouteSettings * _Nullable)previousRouteSettings {
  ThrioRegistrySet *routeObservers = [self.routeObservers copy];
  for (id<NavigatorRouteObserverProtocol> observer in routeObservers) {
    [observer didPop:routeSettings previousRoute:previousRouteSettings];
  }
}

+ (void)didPopTo:(NavigatorRouteSettings *)routeSettings
   previousRoute:(NavigatorRouteSettings * _Nullable)previousRouteSettings {
  ThrioRegistrySet *routeObservers = [self.routeObservers copy];
  for (id<NavigatorRouteObserverProtocol> observer in routeObservers) {
    [observer didPopTo:routeSettings previousRoute:previousRouteSettings];
  }
}

+ (void)didRemove:(NavigatorRouteSettings *)routeSettings
    previousRoute:(NavigatorRouteSettings * _Nullable)previousRouteSettings {
  ThrioRegistrySet *routeObservers = [self.routeObservers copy];
  for (id<NavigatorRouteObserverProtocol> observer in routeObservers) {
    [observer didRemove:routeSettings previousRoute:previousRouteSettings];
  }
}

@end

NS_ASSUME_NONNULL_END
