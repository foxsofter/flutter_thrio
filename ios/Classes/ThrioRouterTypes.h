//
//  ThrioRouterTypes.h
//  thrio_router
//
//  Created by foxsofter on 2019/12/9.
//

#import <Foundation/Foundation.h>

#import "ThrioRouterRouteSettings.h"

#ifndef ThrioRouterTypes_h
#define ThrioRouterTypes_h


// Signature for a block that handlers channel method invocation.
//
typedef id (^ThrioMethodHandler)(NSDictionary *arguments);

// Signature for a block that handlers channel event handling.
//
typedef id (^ThrioEventHandler)(NSDictionary *arguments);

// Signature of callbacks that have no arguments.
//
typedef void (^ThrioVoidCallback)(void);

// Signature of callbacks with boolean parameters.
//
typedef void (^ThrioBoolCallback)(BOOL);


// Signature for a block that creates a UIViewController.
//
typedef UIViewController* (^ThrioPageBuilder)(NSDictionary<NSString *, id>* params);

// States that a router container can be in.
//
typedef NS_ENUM(NSUInteger, ThrioRouterContainerLifecycle) {
  ThrioRouterContainerLifecycleInited,
  ThrioRouterContainerLifecycleWillAppear,
  ThrioRouterContainerLifecycleAppeared,
  ThrioRouterContainerLifecycleWillDisappeared,
  ThrioRouterContainerLifecycleDestroyed,
  ThrioRouterContainerLifecycleBackground,
  ThrioRouterContainerLifecycleForeground,
};

// Signature for a method that handlers a router container lifecycle event.
//
typedef void (^ThrioRouterContainerLifecycleHandler)
             (ThrioRouterRouteSettings *routeSettings,
              ThrioRouterContainerLifecycle lifecycle);

// A router container available navigation actions.
//
typedef NS_ENUM(NSUInteger, ThrioRouterContainerNavigation) {
  ThrioRouterContainerNavigationPush,
  ThrioRouterContainerNavigationActivate,
  ThrioRouterContainerNavigationPop,
  ThrioRouterContainerNavigationRemove,
};

#endif /* ThrioRouterTypes_h */
