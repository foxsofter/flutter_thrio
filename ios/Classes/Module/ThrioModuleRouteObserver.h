//
//  ThrioModuleRouteObserver.h
//  Pods-Runner
//
//  Created by Wei ZhongDan on 2020/10/2.
//

#import <Foundation/Foundation.h>
#import "ThrioTypes.h"
#import "ThrioModule.h"
#import "NavigatorRouteObserverProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ThrioModuleRouteObserver <NSObject>

/// Register observers for route action of native pages and Dart pages.
///
/// Do not override this method.
///
- (ThrioVoidCallback)registerRouteObserver:(id<NavigatorRouteObserverProtocol>)routeObserver;

@end

@class ThrioModule;

@interface ThrioModule (RouteObserver) <ThrioModuleRouteObserver>

@end

NS_ASSUME_NONNULL_END
