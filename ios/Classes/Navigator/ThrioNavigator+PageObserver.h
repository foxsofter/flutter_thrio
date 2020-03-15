//
//  ThrioNavigator+Observer.h
//  thrio
//
//  Created by fox softer on 2020/3/14.
//

#import <Foundation/Foundation.h>
#import "ThrioNavigator.h"
#import "ThrioRegistrySet.h"
#import "NavigatorPageObserverProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioNavigator (PageObserver)

+ (ThrioRegistrySet<id<NavigatorPageObserverProtocol>> *)pageObservers;

+ (void)onCreate:(NavigatorRouteSettings *)routeSettings;

+ (void)willAppear:(NavigatorRouteSettings *)routeSettings;

+ (void)didAppear:(NavigatorRouteSettings *)routeSettings;

+ (void)willDisappear:(NavigatorRouteSettings *)routeSettings;

+ (void)didDisappear:(NavigatorRouteSettings *)routeSettings;

@end

NS_ASSUME_NONNULL_END
