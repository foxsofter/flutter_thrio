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
#import <objc/runtime.h>
#import "UINavigationController+Navigator.h"
#import "UINavigationController+PopGesture.h"
#import "UIViewController+WillPopCallback.h"
#import "UIViewController+Navigator.h"
#import "UIViewController+Internal.h"
#import "UIViewController+HidesNavigationBar.h"
#import "NavigatorFlutterEngineFactory.h"
#import "ThrioNavigator+PageObservers.h"
#import "NavigatorLogger.h"
#import "NavigatorFlutterViewController.h"
#import "NSObject+ThrioSwizzling.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController ()

@property (nonatomic, strong, readwrite, nullable) NavigatorPageRoute *thrio_firstRoute;

@end

@implementation UIViewController (Navigator)

- (NavigatorPageRoute * _Nullable)thrio_firstRoute {
  return objc_getAssociatedObject(self, @selector(setThrio_firstRoute:));
}

- (void)setThrio_firstRoute:(NavigatorPageRoute * _Nullable)route {
  objc_setAssociatedObject(self,
                           @selector(setThrio_firstRoute:),
                           route,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NavigatorPageRoute * _Nullable)thrio_lastRoute {
  NavigatorPageRoute *next = self.thrio_firstRoute;
  while (next.next) {
    next = next.next;
  }
  return next;
}

#pragma mark - Navigation methods

- (void)thrio_pushUrl:(NSString *)url
                index:(NSNumber *)index
               params:(id _Nullable)params
             animated:(BOOL)animated
       fromEntrypoint:(NSString * _Nullable)entrypoint
               result:(ThrioNumberCallback _Nullable)result
         poppedResult:(ThrioIdCallback _Nullable)poppedResult {
  NavigatorRouteSettings *settings = [NavigatorRouteSettings settingsWithUrl:url
                                                                       index:index
                                                                      nested:self.thrio_firstRoute != nil
                                                                      params:params];
  if (![self isKindOfClass:NavigatorFlutterViewController.class]) { // 当前页面为原生页面
    [ThrioNavigator onCreate:settings];
  }
  NavigatorPageRoute *newRoute = [NavigatorPageRoute routeWithSettings:settings];
  newRoute.fromEntrypoint = entrypoint;
  newRoute.poppedResult = poppedResult;
  if (self.thrio_firstRoute) {
    NavigatorPageRoute *lastRoute = self.thrio_lastRoute;
    lastRoute.next = newRoute;
    newRoute.prev = lastRoute;
  } else {
    self.thrio_firstRoute = newRoute;
  }
  if ([self isKindOfClass:NavigatorFlutterViewController.class]) {
    NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithDictionary:[settings toArguments]];
    [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
    NSString *entrypoint = [(NavigatorFlutterViewController*)self entrypoint];
    NavigatorRouteSendChannel *channel = [NavigatorFlutterEngineFactory.shared getSendChannelByEntrypoint:entrypoint];
    if (result) {
      [channel onPush:arguments result:^(id _Nullable r) {
        result(r && [r boolValue] ? index : nil);
      }];
    } else {
      [channel onPush:arguments result:nil];
    }
  } else if (result) {
    result(index);
  }
}

- (BOOL)thrio_notifyUrl:(NSString *)url
                  index:(NSNumber * _Nullable)index
                   name:(NSString *)name
                 params:(id _Nullable)params {
  BOOL isMatch = NO;

  NavigatorPageRoute *last = self.thrio_lastRoute;
  do {
    if ([last.settings.url isEqualToString:url] &&
        (index == nil || [last.settings.index isEqualToNumber:index])) {
      [last addNotify:name params:params];
      if (self == self.navigationController.topViewController &&
          last == self.thrio_lastRoute) {
        [self thrio_onNotify:last];
      }
      isMatch = YES;
    }
  } while ((last = last.prev));

  return isMatch;
}

- (void)thrio_popParams:(id _Nullable)params
               animated:(BOOL)animated
                 result:(ThrioBoolCallback _Nullable)result {
  NavigatorPageRoute *route = self.thrio_lastRoute;
  if (!route) {
    if (result) {
      result(NO);
    }
    return;
  }
  NSMutableDictionary *arguments =
    [NSMutableDictionary dictionaryWithDictionary:[route.settings toArgumentsWithParams:params]];
  [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];

  if ([self isKindOfClass:NavigatorFlutterViewController.class]) {
    NSString *entrypoint = [(NavigatorFlutterViewController*)self entrypoint];
    NavigatorRouteSendChannel *channel = [NavigatorFlutterEngineFactory.shared getSendChannelByEntrypoint:entrypoint];
    __weak typeof(self) weakself = self;
    // 发送给需要关闭页面的引擎
    [channel onPop:arguments result:^(id _Nullable r) {
      __strong typeof(weakself) strongSelf = weakself;
      if (r && [r boolValue]) {
        if (route != strongSelf.thrio_firstRoute) {
          [strongSelf thrio_onNotify:route.prev];
        }
      }
      if (result) {
        result(r && [r boolValue]);
      }

      // 关闭成功,处理页面回传参数
      if (r && [r boolValue]) {
        if (route.poppedResult) {
          route.poppedResult(params);
        }
        // 检查打开页面的源引擎是否和关闭页面的源引擎不同，不同则继续发送onPop
        if (route.fromEntrypoint && ![route.fromEntrypoint isEqualToString:entrypoint]) {
          NavigatorRouteSendChannel *channel = [NavigatorFlutterEngineFactory.shared getSendChannelByEntrypoint:route.fromEntrypoint];
          [channel onPop:arguments result:nil];
        }
      }
    }];
  } else {
    if (result) {
      // 原生页面一定只有一个route
      result(route == self.thrio_firstRoute);
    }
    if (route == self.thrio_firstRoute) {
      // 关闭成功,处理页面回传参数
      if (route.poppedResult) {
        route.poppedResult(params);
      }
      // 检查打开页面的源引擎是否和关闭页面的源引擎不同，不同则继续发送onPop
      if (route.fromEntrypoint) {
        NavigatorRouteSendChannel *channel = [NavigatorFlutterEngineFactory.shared getSendChannelByEntrypoint:route.fromEntrypoint];
        [channel onPop:arguments result:nil];
      }
    }
  }
}

- (void)thrio_popToUrl:(NSString *)url
                 index:(NSNumber * _Nullable)index
              animated:(BOOL)animated
                result:(ThrioBoolCallback _Nullable)result {
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (!route) {
    if (result) {
      result(NO);
    }
    return;
  }
  // 是最顶层页面，无法popTo
  if (self.thrio_lastRoute == route && self == self.navigationController.topViewController) {
    if (result) {
      result(NO);
    }
    return;
  }
  if ([self isKindOfClass:NavigatorFlutterViewController.class]) {
    NSMutableDictionary *arguments =
    [NSMutableDictionary dictionaryWithDictionary:[route.settings toArgumentsWithParams:nil]];
    [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
    __weak typeof(self) weakself = self;
    NSString *entrypoint = [(NavigatorFlutterViewController*)self entrypoint];
    NavigatorRouteSendChannel *channel = [NavigatorFlutterEngineFactory.shared getSendChannelByEntrypoint:entrypoint];
    [channel onPopTo:arguments result:^(id _Nullable r) {
      __strong typeof(weakself) strongSelf = weakself;
      if (r && [r boolValue]) {
        route.next = nil; // TODO: 多引擎模式下，同步各个引擎的页面
        [strongSelf thrio_onNotify:route];
      }
      if (result) {
        result(r && [r boolValue]);
      }
    }];
  } else {
    [self thrio_onNotify:route];
    if (result) {
      result(YES);
    }
  }
}

- (void)thrio_removeUrl:(NSString *)url
                  index:(NSNumber * _Nullable)index
               animated:(BOOL)animated
                 result:(ThrioBoolCallback _Nullable)result {
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (!route) {
    if (result) {
      result(NO);
    }
    return;
  }
  if ([self isKindOfClass:NavigatorFlutterViewController.class]) {
    NSMutableDictionary *arguments =
    [NSMutableDictionary dictionaryWithDictionary:[route.settings toArgumentsWithParams:nil]];
    [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
    __weak typeof(self) weakself = self;
    NSString *entrypoint = [(NavigatorFlutterViewController*)self entrypoint];
    NavigatorRouteSendChannel *channel = [NavigatorFlutterEngineFactory.shared getSendChannelByEntrypoint:entrypoint];
    [channel onRemove:arguments result:^(id  _Nullable r) {
      __strong typeof(weakself) strongSelf = weakself;
      if ([r boolValue]) {
        if (route == strongSelf.thrio_firstRoute) {
          strongSelf.thrio_firstRoute = route.next;
          route.prev.next = nil;
        } else if (route == strongSelf.thrio_lastRoute) {
          route.prev.next = nil;
          [strongSelf thrio_onNotify:route.prev];
        } else {
          route.prev.next = route.next;
          route.next.prev = route.prev;
        }
      }
      if (result) {
        result(r && [r boolValue]);
      }
    }];
  } else {
    if (route == self.thrio_firstRoute) {
      self.thrio_firstRoute = route.next;
      self.thrio_firstRoute.prev = nil;
    } else if (route == self.thrio_lastRoute) {
      route.prev.next = nil;
      [self thrio_onNotify:route.prev];
    } else {
      route.prev.next = route.next;
      route.next.prev = route.prev;
    }
    if (result) {
      result(YES);
    }
  }
}

- (void)thrio_didPushUrl:(NSString *)url index:(NSNumber *)index {
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (!route) {
    self.thrio_lastRoute.next = route;
    route.prev = self.thrio_lastRoute;
  }
}

- (void)thrio_didPopUrl:(NSString *)url index:(NSNumber *)index {
  // didPop来自于Dart侧滑关掉的页面，只需要同步route的状态，发出页面通知即可
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (route) {
    route.prev.next = nil;
    [self thrio_onNotify:route.prev];
  }
}

- (void)thrio_didPopToUrl:(NSString *)url index:(NSNumber *)index {
  // didPopTo来自于Dart侧直接调用Navigator的行为，只需要同步route的状态，发出页面通知即可
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (route) {
    route.next = nil;
    [self thrio_onNotify:route];
  }
}

- (void)thrio_didRemoveUrl:(NSString *)url index:(NSNumber *)index {
  // didRemove来自于Dart侧直接调用Navigator的行为，只需要同步route的状态，发出页面通知即可
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (route) {
    if (route == self.thrio_firstRoute) {
      self.thrio_firstRoute = route.next;
      self.thrio_firstRoute.prev = nil;
    } else if (route == self.thrio_lastRoute) {
      route.prev.next = nil;
      [self thrio_onNotify:route.prev];
    } else {
      route.prev.next = route.next;
      route.next.prev = route.prev;
    }
  }
}

- (NavigatorPageRoute * _Nullable)thrio_getRouteByUrl:(NSString *)url
                                                index:(NSNumber * _Nullable)index {
  NavigatorPageRoute *last = self.thrio_lastRoute;
  if (url.length < 1) {
    return last;
  }
  do {
    if ([last.settings.url isEqualToString:url] &&
        (index == nil || [last.settings.index isEqualToNumber:index])) {
      return last;
    }
  } while ((last = last.prev));
  return nil;
}

- (NSNumber * _Nullable)thrio_getLastIndexByUrl:(NSString *)url {
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:nil];
  return route.settings.index;
}

- (NSArray *)thrio_getAllIndexByUrl:(NSString *)url {
  NSMutableArray *indexs = [NSMutableArray array];
  NavigatorPageRoute *first = self.thrio_firstRoute;
  do {
    if ([first.settings.url isEqualToString:url]) {
      [indexs addObject:first.settings.index];
    }
  } while ((first = first.next));
  return [indexs copy];
}


#pragma mark - method swizzling

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self instanceSwizzle:@selector(viewWillAppear:)
              newSelector:@selector(thrio_viewWillAppear:)];
    [self instanceSwizzle:@selector(viewDidAppear:)
              newSelector:@selector(thrio_viewDidAppear:)];
    [self instanceSwizzle:@selector(viewWillDisappear:)
              newSelector:@selector(thrio_viewWillDisappear:)];
    [self instanceSwizzle:@selector(viewDidDisappear:)
              newSelector:@selector(thrio_viewDidDisappear:)];
  });
}

- (void)thrio_viewWillAppear:(BOOL)animated {
  [self thrio_viewWillAppear:animated];
  
  if (self.thrio_firstRoute && ![self isKindOfClass:NavigatorFlutterViewController.class]) {
    [ThrioNavigator willAppear:self.thrio_lastRoute.settings];
  }
}

- (void)thrio_viewDidAppear:(BOOL)animated {
  [self thrio_viewDidAppear:animated];
  
  // 如果侧滑返回的手势放弃，需要清除thrio_popingViewController标记
  if (self.navigationController.thrio_popingViewController == self) {
    self.navigationController.thrio_popingViewController = nil;
  }
  
  if (self.thrio_firstRoute && ![self isKindOfClass:NavigatorFlutterViewController.class]) {
    [ThrioNavigator didAppear:self.thrio_lastRoute.settings];
  }

  if (self.thrio_firstRoute &&
      ([self isKindOfClass:NavigatorFlutterViewController.class] ||
      [self conformsToProtocol:@protocol(NavigatorPageNotifyProtocol)])) {
    // 当页面出现后，给页面发送通知
    [self thrio_onNotify:self.thrio_lastRoute];
  }
  
  if (![self isKindOfClass:NavigatorFlutterViewController.class]) {
    if (self.thrio_hidesNavigationBar_ == nil) {
      self.thrio_hidesNavigationBar_ = @(self.navigationController.navigationBarHidden);
    }
    if (self.thrio_willPopBlock) {
      self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
  } else {
    if (self.thrio_firstRoute == self.thrio_lastRoute) {
      [self.navigationController thrio_addPopGesture];
    } else {
      [self.navigationController thrio_removePopGesture];
    }
  }
  if (self.thrio_hidesNavigationBar_.boolValue != self.navigationController.navigationBarHidden) {
    self.navigationController.navigationBarHidden = self.thrio_hidesNavigationBar_.boolValue;
  }
  if (self.navigationController.navigationBarHidden) {
    [self.navigationController thrio_addPopGesture];
  } else {
    [self.navigationController thrio_removePopGesture];
  }
}

- (void)thrio_viewWillDisappear:(BOOL)animated {
  [self thrio_viewWillDisappear:animated];
  
  if (self.thrio_firstRoute && ![self isKindOfClass:NavigatorFlutterViewController.class]) {
    [ThrioNavigator willDisappear:self.thrio_lastRoute.settings];
  }
}

- (void)thrio_viewDidDisappear:(BOOL)animated {
  [self thrio_viewDidDisappear:animated];
  [self.navigationController thrio_removePopGesture];
  
  if (self.thrio_firstRoute && ![self isKindOfClass:NavigatorFlutterViewController.class]) {
    [ThrioNavigator didDisappear:self.thrio_lastRoute.settings];
  }
}

- (void)thrio_onNotify:(NavigatorPageRoute *)route {
  NSArray *keys = [route.notifications.allKeys copy];
  for (NSString *name in keys) {
    id params = [route removeNotify:name];
    if ([self isKindOfClass:NavigatorFlutterViewController.class]) {
      NSDictionary *arguments = params ? @{
        @"url": route.settings.url,
        @"index": route.settings.index,
        @"name": name,
        @"params": params,
      } : @{
        @"url": route.settings.url,
        @"index": route.settings.index,
        @"name": name,
      };
      NSString *entrypoint = [(NavigatorFlutterViewController*)self entrypoint];
      NavigatorRouteSendChannel *channel = [NavigatorFlutterEngineFactory.shared getSendChannelByEntrypoint:entrypoint];
      [channel onNotify:arguments result:nil];
    } else {
      if ([self conformsToProtocol:@protocol(NavigatorPageNotifyProtocol)]) {
        [(id<NavigatorPageNotifyProtocol>)self onNotify:name params:params];
      }
    }
  }
}

@end

NS_ASSUME_NONNULL_END
