//
//  ThrioTypes.h
//  thrio
//
//  Created by foxsofter on 2019/12/9.
//

#import <Foundation/Foundation.h>

#ifndef ThrioTypes_h
#define ThrioTypes_h

NS_ASSUME_NONNULL_BEGIN

// Signature for a block that handlers channel method invocation.
//
typedef id _Nullable (^ThrioMethodHandler)(NSDictionary<NSString *, id> *arguments);

// Signature for a block that handlers channel event handling.
//
typedef id _Nullable (^ThrioEventHandler)(NSDictionary<NSString *, id> *arguments);

// Signature of callbacks that have no arguments.
//
typedef void (^ThrioVoidCallback)(void);

// Signature of callbacks with boolean parameters.
//
typedef void (^ThrioBoolCallback)(BOOL);

// Signature of predicate that can pop or not.
//
typedef BOOL (^ThrioPopPredicate)
             (NSString *url,
              NSNumber * _Nullable index);

// Signature for a block that creates a UIViewController.
//
typedef  UIViewController* _Nullable  (^ThrioPageBuilder)(NSDictionary<NSString *, id>* params);

// States that a router page can be in.
//
typedef NS_ENUM(NSUInteger, ThrioPageLifecycle) {
  ThrioPageLifecycleInited,
  ThrioPageLifecycleWillAppear,
  ThrioPageLifecycleAppeared,
  ThrioPageLifecycleWillDisappeared,
  ThrioPageLifecycleDisappeared,
  ThrioPageLifecycleDestroyed,
  ThrioPageLifecycleBackground,
  ThrioPageLifecycleForeground,
};

// Signature for a function that handlers a router page lifecycle.
//
//typedef void (^ThrioPageLifecycleHandler)
//             (ThrioRouteSettings *routeSettings,
//              ThrioPageLifecycle lifecycle);

// A router available navigation event.
//
typedef NS_ENUM(NSUInteger, ThrioNavigationEvent) {
  ThrioNavigationEventPush,
  ThrioNavigationEventActivate,
  ThrioNavigationEventPop,
  ThrioNavigationEventRemove,
};

NS_ASSUME_NONNULL_END

#endif /* ThrioTypes_h */

