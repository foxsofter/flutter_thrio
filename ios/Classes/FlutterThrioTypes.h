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

#import <UIKit/UIKit.h>

#ifndef FlutterThrioTypes_h
#define FlutterThrioTypes_h

NS_ASSUME_NONNULL_BEGIN

@class NavigatorFlutterEngine;
@class NavigatorFlutterViewController;

/// Signature of callbacks that have no arguments.
///
typedef void (^ThrioVoidCallback)(void);

/// Signature of callbacks with boolean parameters.
///
typedef void (^ThrioBoolCallback)(BOOL);

/// Signature of callbacks with NSNumber parameters.
///
typedef void (^ThrioNumberCallback)(NSNumber *_Nullable);

/// Signature of callbacks with id parameters.
///
typedef void (^ThrioIdCallback)(id _Nullable);

/// Signature for a callback that verifies that it's true or false.
///
typedef void (^ThrioWillPopCallback)(ThrioBoolCallback);

/// Signature for a block that handlers channel method invocation.
///
typedef void (^ThrioMethodHandler)(NSDictionary<NSString *, id> *arguments, ThrioIdCallback _Nullable result);

/// Signature for a block that handlers channel event handling.
///
typedef void (^ThrioEventHandler)(NSDictionary<NSString *, id> *arguments, ThrioIdCallback _Nullable result);

/// Signature of a block that creates a NavigatorFlutterViewController.
///
typedef NavigatorFlutterViewController *_Nullable (^NavigatorFlutterPageBuilder)(NavigatorFlutterEngine *engine);

/// Signature for a block that creates a native UIViewController.
///
typedef UIViewController *_Nullable (^NavigatorPageBuilder)(id _Nullable params);

/// Signature of callbacks with `NavigatorFlutterEngine` parameters.
///
typedef void (^ThrioEngineReadyCallback)(NavigatorFlutterEngine *);

NS_ASSUME_NONNULL_END

#endif /* FlutterThrioTypes_h */
