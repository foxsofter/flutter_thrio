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


#import "ThrioModule.h"
#import "ThrioNavigator+PageBuilders.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioNavigator+PageObservers.h"
#import "ThrioNavigator+RouteObservers.h"
#import "NavigatorFlutterEngineFactory.h"

@implementation ThrioModule

static NSMutableDictionary *modules;

+ (void)init:(ThrioModule *)rootModule {
  [rootModule registerModule:rootModule];
  [rootModule initModule];
}

- (void)registerModule:(ThrioModule *)module {
  if (!modules) {
    modules = [NSMutableDictionary dictionary];
  }
  NSString *key = NSStringFromClass([module class]);
  if ([[modules allKeys] containsObject:key]) {
    [NSException raise:@"Duplicate registration exception"
                format:@"%@ already registered", key];
  }
  [modules setObject:module forKey:key];
  [module onModuleRegister];
}

- (void)initModule {
  NSArray *values = modules.allValues;
  for (ThrioModule *module in values) {
    if ([module respondsToSelector:@selector(onPageRegister)]) {
      [module onPageRegister];
    }
  }
  for (ThrioModule *module in values) {
    if ([module respondsToSelector:@selector(onModuleInit)]) {
      [module onModuleInit];
    }
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    for (ThrioModule *module in values) {
      if ([module respondsToSelector:@selector(onModuleAsyncInit)]) {
        [module onModuleAsyncInit];
      }
    }
  });
  // 单引擎模式下，提前启动
  if (!ThrioNavigator.isMultiEngineEnabled) {
    [NavigatorFlutterEngineFactory.shared startupWithEntrypoint:@"" readyBlock:nil];
  }
}

- (void)onModuleRegister { }

- (void)onPageRegister { }

- (void)onModuleInit { }

- (void)onModuleAsyncInit { }

- (ThrioVoidCallback)registerPageBuilder:(NavigatorPageBuilder)builder
                                  forUrl:(NSString *)url {
  return [ThrioNavigator.pageBuilders registry:url value:builder];
}

- (void)setFlutterPageBuilder:(NavigatorFlutterPageBuilder)builder {
  ThrioNavigator.flutterPageBuilder = builder;
}

- (ThrioVoidCallback)registerPageObserver:(id<NavigatorPageObserverProtocol>)pageObserver {
  return [ThrioNavigator.pageObservers registry:pageObserver];
}

- (ThrioVoidCallback)registerRouteObserver:(id<NavigatorRouteObserverProtocol>)routeObserver {
  return [ThrioNavigator.routeObservers registry:routeObserver];
}

- (void)startupFlutterEngineWithEntrypoint:(NSString *)entrypoint {
  [NavigatorFlutterEngineFactory.shared startupWithEntrypoint:entrypoint readyBlock:nil];
}


@end
