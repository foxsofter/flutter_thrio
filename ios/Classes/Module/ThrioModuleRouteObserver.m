//
//  ThrioModuleRouteObserver.m
//  Pods-Runner
//
//  Created by Wei ZhongDan on 2020/10/2.
//

#import "ThrioModuleRouteObserver.h"
#import "ThrioNavigator+RouteObservers.h"

@implementation ThrioModule (RouteObserver)

- (ThrioVoidCallback)registerRouteObserver:(id<NavigatorRouteObserverProtocol>)routeObserver {
    return [ThrioNavigator.routeObservers registry:routeObserver];
}

@end
