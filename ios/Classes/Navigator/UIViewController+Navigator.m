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
#import "UINavigationController+FlutterEngine.h"
#import "UIViewController+Navigator.h"
#import "ThrioNavigator.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioLogger.h"
#import "ThrioFlutterViewController.h"
#import "NSObject+ThrioSwizzling.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController ()

@property (nonatomic, strong, readwrite, nullable) NavigatorPageRoute *thrio_firstRoute;

@end

@implementation UIViewController (Navigator)


- (NSNumber * _Nullable)thrio_hidesNavigationBar {
  return objc_getAssociatedObject(self, @selector(setThrio_hidesNavigationBar:));
}

- (void)setThrio_hidesNavigationBar:(NSNumber * _Nullable)hidesNavigationBarWhenPushed {
  objc_setAssociatedObject(self,
                           @selector(setThrio_hidesNavigationBar:),
                           hidesNavigationBarWhenPushed,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

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
               params:(NSDictionary *)params
             animated:(BOOL)animated
               result:(ThrioBoolCallback)result{
  NavigatorRouteSettings *settings = [NavigatorRouteSettings settingsWithUrl:url
                                                               index:index
                                                              nested:self.thrio_firstRoute != nil
                                                              params:params];
  NavigatorPageRoute *newRoute = [NavigatorPageRoute routeWithSettings:settings];
  if (self.thrio_firstRoute) {
    NavigatorPageRoute *lastRoute = self.thrio_lastRoute;
    lastRoute.next = newRoute;
    newRoute.prev = lastRoute;
  } else {
    self.thrio_firstRoute = newRoute;
  }
  if ([self isKindOfClass:ThrioFlutterViewController.class]) {
    NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithDictionary:[settings toArguments]];
    [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
    ThrioChannel *channel = [ThrioNavigator.navigationController thrio_getChannelForEntrypoint:[(ThrioFlutterViewController*)self entrypoint]];
    [channel invokeMethod:@"__onPush__"
                arguments:arguments
                   result:^(id _Nullable r) {
      result(r && [r boolValue]);
    }];
  } else {
    result(YES);
  }
}

- (BOOL)thrio_notifyUrl:(NSString *)url
                  index:(NSNumber *)index
                   name:(NSString *)name
                 params:(NSDictionary *)params {
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (route) {
    [route addNotify:name params:params];
    if (self == self.navigationController.topViewController) {
      [self thrio_onNotify];
    }
    return YES;
  }
  return NO;
}

- (void)thrio_popAnimated:(BOOL)animated result:(ThrioBoolCallback)result {
  NavigatorPageRoute *route = self.thrio_lastRoute;
  if (!route) {
    result(NO);
    return;
  }
  if ([self isKindOfClass:ThrioFlutterViewController.class]) {
    NSMutableDictionary *arguments =
      [NSMutableDictionary dictionaryWithDictionary:[route.settings toArgumentsWithoutParams]];
    [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
    __weak typeof(self) weakself = self;
    NSString *entrypoint = [(ThrioFlutterViewController*)self entrypoint];
    ThrioChannel *channel = [self.navigationController thrio_getChannelForEntrypoint:entrypoint];
    [channel invokeMethod:@"__onPop__"
                arguments:arguments
                   result:^(id _Nullable r) {
      __strong typeof(self) strongSelf = weakself;
      if ([r boolValue]) {
        if (route != strongSelf.thrio_firstRoute) {
          route.prev.next = nil;
          [strongSelf thrio_onNotify];
        } else {
          strongSelf.thrio_firstRoute = nil;
        }
      }
      result([r boolValue]);
    }];
  } else {
    if (route != self.thrio_firstRoute) {
      route.prev.next = nil;
      [self thrio_onNotify];
    } else {
      self.thrio_firstRoute = nil;
    }
    result(YES);
  }
}

- (void)thrio_popToUrl:(NSString *)url
                 index:(NSNumber *)index
              animated:(BOOL)animated
                result:(ThrioBoolCallback)result {
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (!route) {
    result(NO);
    return;
  }
  if ([self isKindOfClass:ThrioFlutterViewController.class]) {
    NSMutableDictionary *arguments =
      [NSMutableDictionary dictionaryWithDictionary:[route.settings toArgumentsWithoutParams]];
    [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
    __weak typeof(self) weakself = self;
    ThrioChannel *channel = [self.navigationController thrio_getChannelForEntrypoint:[(ThrioFlutterViewController*)self entrypoint]];
    [channel invokeMethod:@"__onPopTo__"
                arguments:arguments
                   result:^(id  _Nullable r) {
      __strong typeof(self) strongSelf = weakself;
      if ([r boolValue]) {
        route.next = nil;
        [strongSelf thrio_onNotify];
      }
      result(r && [r boolValue]);
    }];
  } else {
    route.next = nil;
    [self thrio_onNotify];
    result(YES);
  }
}

- (void)thrio_removeUrl:(NSString *)url
                  index:(NSNumber *)index
               animated:(BOOL)animated
                 result:(ThrioBoolCallback)result {
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (!route) {
    result(NO);
    return;
  }
  if ([self isKindOfClass:ThrioFlutterViewController.class]) {
    NSMutableDictionary *arguments =
      [NSMutableDictionary dictionaryWithDictionary:[route.settings toArgumentsWithoutParams]];
    [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
    __weak typeof(self) weakself = self;
    ThrioChannel *channel = [self.navigationController thrio_getChannelForEntrypoint:[(ThrioFlutterViewController*)self entrypoint]];
    [channel invokeMethod:@"__onRemove__"
                arguments:arguments
                   result:^(id  _Nullable r) {
      __strong typeof(self) strongSelf = weakself;
      if ([r boolValue]) {
        if (route == strongSelf.thrio_firstRoute) {
          strongSelf.thrio_firstRoute = route.next;
          strongSelf.thrio_firstRoute.prev = nil;
        } else if (route == strongSelf.thrio_lastRoute) {
          route.prev.next = nil;
          [strongSelf thrio_onNotify];
        } else {
          route.prev.next = route.next;
          route.next.prev = route.prev;
        }
      }
      result(r && [r boolValue]);
    }];
  } else {
    if (route == self.thrio_firstRoute) {
      self.thrio_firstRoute = route.next;
      self.thrio_firstRoute.prev = nil;
    } else if (route == self.thrio_lastRoute) {
      route.prev.next = nil;
      [self thrio_onNotify];
    } else {
      route.prev.next = route.next;
      route.next.prev = route.prev;
    }
    result(YES);
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
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (route) {
    route.prev.next = nil;
    [self thrio_onNotify];
  }
}

- (void)thrio_didPopToUrl:(NSString *)url index:(NSNumber *)index {
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (route) {
    route.next = nil;
    [self thrio_onNotify];
  }
}

- (void)thrio_didRemoveUrl:(NSString *)url index:(NSNumber *)index {
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (route) {
    if (route == self.thrio_firstRoute) {
      self.thrio_firstRoute = route.next;
      self.thrio_firstRoute.prev = nil;
    } else if (route == self.thrio_lastRoute) {
      route.prev.next = nil;
      [self thrio_onNotify];
    } else {
      route.prev.next = route.next;
      route.next.prev = route.prev;
    }
  }
}

- (NavigatorPageRoute * _Nullable)thrio_getRouteByUrl:(NSString *)url index:(NSNumber *)index {
  NavigatorPageRoute *last = self.thrio_lastRoute;
  if (url.length < 1) {
    return last;
  }
  do {
    if ([last.settings.url isEqualToString:url] &&
        ([index isEqualToNumber:@0] || [last.settings.index isEqualToNumber:index])) {
      return last;
    }
  } while ((last = last.prev));
  return nil;
}

- (NSNumber *)thrio_getLastIndexByUrl:(NSString *)url {
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:@0];
  return route ? route.settings.index : @0;
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
    [self instanceSwizzle:@selector(viewDidAppear:)
              newSelector:@selector(thrio_viewDidAppear:)];
    [self instanceSwizzle:@selector(viewDidDisappear:)
              newSelector:@selector(thrio_viewDidDisappear:)];
  });
}

- (void)thrio_viewDidAppear:(BOOL)animated {
  [self thrio_viewDidAppear:animated];
  
  if ([self isKindOfClass:ThrioFlutterViewController.class] ||
      [self conformsToProtocol:@protocol(NavigatorNotifyProtocol)]) {
    // 当页面出现后，给页面发送通知
    [self thrio_onNotify];
  }
  
  if (![self isKindOfClass:ThrioFlutterViewController.class]) {
    if (self.thrio_hidesNavigationBar == nil) {
      self.thrio_hidesNavigationBar = @(self.navigationController.navigationBarHidden);
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
  if (self.thrio_hidesNavigationBar.boolValue != self.navigationController.navigationBarHidden) {
    self.navigationController.navigationBarHidden = self.thrio_hidesNavigationBar.boolValue;
  }
}

- (void)thrio_viewDidDisappear:(BOOL)animated {
  [self thrio_viewDidDisappear:animated];
  [self.navigationController thrio_removePopGesture];
}

- (void)thrio_onNotify {
  NavigatorPageRoute *route = self.thrio_lastRoute;
  NSArray *keys = [route.notifications.allKeys copy];
  for (NSString *name in keys) {
    NSDictionary * params = [route removeNotify:name];
    if ([self isKindOfClass:ThrioFlutterViewController.class]) {
      NSDictionary *arguments = @{
        @"url": route.settings.url,
        @"index": route.settings.index,
        @"name": name,
        @"params": params,
      };
      ThrioChannel *channel = [self.navigationController thrio_getChannelForEntrypoint:[(ThrioFlutterViewController*)self entrypoint]];
      [channel sendEvent:@"__onNotify__" arguments:arguments];
    } else {
      if ([self conformsToProtocol:@protocol(NavigatorNotifyProtocol)]) {
        [(id<NavigatorNotifyProtocol>)self onNotify:name params:params];
      }
    }
  }
}

@end

NS_ASSUME_NONNULL_END
