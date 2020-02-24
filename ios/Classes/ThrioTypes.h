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

/// Signature of callbacks that have no arguments.
///
typedef void (^ThrioVoidCallback)(void);

/// Signature of callbacks with boolean parameters.
///
typedef void (^ThrioBoolCallback)(BOOL);

/// Signature for a callback that verifies that it's OK to call `pop`.
///
typedef void (^ThrioWillPopCallback)(ThrioBoolCallback result);

/// Signature for a block that handlers channel method invocation.
///
typedef void (^ThrioMethodHandler)(NSDictionary<NSString *, id> *arguments, ThrioBoolCallback _Nullable result);

/// Signature for a block that handlers channel event handling.
///
typedef void (^ThrioEventHandler)(NSDictionary<NSString *, id> *arguments, ThrioBoolCallback _Nullable result);

/// Signature of a block that creates a ThrioFlutterViewController.
///
@class ThrioFlutterViewController;
typedef ThrioFlutterViewController* _Nullable (^ThrioFlutterViewControllerBuilder)(void);

/// Signature for a block that creates a native UIViewController.
///
typedef UIViewController* _Nullable (^ThrioNativeViewControllerBuilder)(NSDictionary<NSString *, id>* params);


NS_ASSUME_NONNULL_END

#endif /* ThrioTypes_h */

