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

#import <Foundation/Foundation.h>
#import "ThrioTypes.h"
#import "NavigatorPageObserverProtocol.h"
#import "NavigatorRouteObserverProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioModule : NSObject

/// Module entrypoint method.
///
+ (void)init:(ThrioModule *)rootModule;

/// A function for registering a module.
///
/// Should be called in `onModuleRegister`.
///
- (void)registerModule:(ThrioModule *)module;

/// A function for module initialization that will call  the `onPageRegister`, `onModuleInit` and `onModuleAsyncInit`
/// methods of all modules.
///
/// Should only be called once when the app startups.
///
- (void)initModule;

/// A function for registering submodules.
///
- (void)onModuleRegister;

/// A function for registering page builders.
///
- (void)onPageRegister;

/// A function for module initialization.
///
- (void)onModuleInit;

/// A function for module asynchronous initialization.
///
- (void)onModuleAsyncInit;

/// Register native view controller builder for url.
///
/// Do not override this method.
///
- (ThrioVoidCallback)registerPageBuilder:(ThrioNativeViewControllerBuilder)builder
                                  forUrl:(NSString *)url;

/// Sets the `ThrioFlutterViewController` builder.
///
/// Need to be register when extending the `ThrioFlutterViewController` class.
///
/// Do not override this method.
///
- (void)setFlutterPageBuilder:(ThrioFlutterViewControllerBuilder)builder;

/// Register observers for the life cycle of native pages and Dart pages.
///
/// Do not override this method.
///
- (ThrioVoidCallback)registerPageObserver:(id<NavigatorPageObserverProtocol>)pageObserver;

/// Register observers for route action of native pages and Dart pages.
///
/// Do not override this method.
///
- (ThrioVoidCallback)registerRouteObserver:(id<NavigatorRouteObserverProtocol>)routeObserver;

/// Startup the flutter engine with `entrypoint`.
///
/// Should be called in `onModuleAsyncInit`. Subsequent calls will return immediately if the entrypoint is the same.
///
/// Do not override this method.
///
- (void)startupFlutterEngineWithEntrypoint:(NSString *)entrypoint;

@end

NS_ASSUME_NONNULL_END
