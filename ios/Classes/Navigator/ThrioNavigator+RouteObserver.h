//
//  ThrioNavigator+RouteObserver.h
//  thrio
//
//  Created by fox softer on 2020/3/15.
//

#import "ThrioNavigator.h"
#import "ThrioNavigator.h"
#import "ThrioRegistrySet.h"
#import "NavigatorRouteObserverProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioNavigator (RouteObserver)

+ (ThrioRegistrySet<id<NavigatorRouteObserverProtocol>> *)routeObservers;

+ (void)didPush:(NavigatorRouteSettings *)routeSettings
  previousRoute:(NavigatorRouteSettings * _Nullable)previousRouteSettings;

+ (void)didPop:(NavigatorRouteSettings *)routeSettings
 previousRoute:(NavigatorRouteSettings * _Nullable)previousRouteSettings;

+ (void)didPopTo:(NavigatorRouteSettings *)routeSettings
   previousRoute:(NavigatorRouteSettings * _Nullable)previousRouteSettings;

+ (void)didRemove:(NavigatorRouteSettings *)routeSettings
    previousRoute:(NavigatorRouteSettings * _Nullable)previousRouteSettings;

@end

NS_ASSUME_NONNULL_END
