//
//  UIViewController+ThrioPageRoute.m
//  thrio
//
//  Created by foxsofter on 2019/12/16.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "UINavigationController+ThrioNavigator.h"
#import "UIViewController+ThrioPageRoute.h"
#import "ThrioApp.h"
#import "ThrioLogger.h"
#import "ThrioFlutterViewController.h"
#import "NSObject+ThrioSwizzling.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController ()

@property (nonatomic, strong, readwrite, nullable) ThrioPageRoute *thrio_firstRoute;

@end

@implementation UIViewController (ThrioPageRoute)

- (BOOL)thrio_popDisabled {
  return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setThrio_popDisabled:(BOOL)disabled {
  objc_setAssociatedObject(self,
                           @selector(thrio_popDisabled),
                           @(disabled),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber * _Nullable)thrio_hidesNavigationBar {
  return objc_getAssociatedObject(self, @selector(setThrio_hidesNavigationBar:));
}

- (void)setThrio_hidesNavigationBar:(NSNumber * _Nullable)hidesNavigationBarWhenPushed {
  objc_setAssociatedObject(self,
                           @selector(setThrio_hidesNavigationBar:),
                           hidesNavigationBarWhenPushed,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ThrioPageRoute * _Nullable)thrio_firstRoute {
  return objc_getAssociatedObject(self, @selector(setThrio_firstRoute:));
}

- (void)setThrio_firstRoute:(ThrioPageRoute * _Nullable)route {
  objc_setAssociatedObject(self,
                           @selector(setThrio_firstRoute:),
                           route,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ThrioPageRoute * _Nullable)thrio_lastRoute {
  ThrioPageRoute *next = self.thrio_firstRoute;
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
  ThrioRouteSettings *settings = [ThrioRouteSettings settingsWithUrl:url
                                                               index:index
                                                              nested:self.thrio_firstRoute != nil
                                                              params:params];
  ThrioPageRoute *newRoute = [ThrioPageRoute routeWithSettings:settings];
  if (self.thrio_firstRoute) {
    ThrioPageRoute *lastRoute = self.thrio_lastRoute;
    lastRoute.next = newRoute;
    newRoute.prev = lastRoute;
  } else {
    self.thrio_firstRoute = newRoute;
  }
  if ([self isKindOfClass:ThrioFlutterViewController.class]) {
    NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithDictionary:[settings toArguments]];
    [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
    [[ThrioApp.shared channel] invokeMethod:@"__onPush__"
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
  ThrioPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (route) {
    [route addNotify:name params:params];
    return YES;
  }
  return NO;
}

- (void)thrio_popAnimated:(BOOL)animated result:(ThrioBoolCallback)result {
  ThrioPageRoute *route = self.thrio_lastRoute;
  if ([self isKindOfClass:ThrioFlutterViewController.class]) {
    NSMutableDictionary *arguments =
      [NSMutableDictionary dictionaryWithDictionary:[route.settings toArgumentsWithoutParams]];
    [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
    __weak typeof(self) weakself = self;
    [[ThrioApp.shared channel] invokeMethod:@"__onPop__"
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
  ThrioPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (!route) {
    result(NO);
    return;
  }
  if ([self isKindOfClass:ThrioFlutterViewController.class]) {
    NSMutableDictionary *arguments =
      [NSMutableDictionary dictionaryWithDictionary:[route.settings toArgumentsWithoutParams]];
    [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
    __weak typeof(self) weakself = self;
    [[ThrioApp.shared channel] invokeMethod:@"__onPopTo__"
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
  ThrioPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (!route) {
    result(NO);
    return;
  }
  if ([self isKindOfClass:ThrioFlutterViewController.class]) {
    NSMutableDictionary *arguments =
      [NSMutableDictionary dictionaryWithDictionary:[route.settings toArgumentsWithoutParams]];
    [arguments setObject:[NSNumber numberWithBool:animated] forKey:@"animated"];
    __weak typeof(self) weakself = self;
    [[ThrioApp.shared channel] invokeMethod:@"__onRemove__"
                                  arguments:arguments
                                     result:^(id  _Nullable r) {
      __strong typeof(self) strongSelf = weakself;
      if ([r boolValue]) {
        if (route == strongSelf.thrio_firstRoute) {
          strongSelf.thrio_firstRoute = route.next;
          strongSelf.thrio_firstRoute.prev = nil;
        } else if (route == self.thrio_lastRoute) {
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
  ThrioPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (!route) {
    self.thrio_lastRoute.next = route;
    route.prev = self.thrio_lastRoute;
  }
}

- (void)thrio_didPopUrl:(NSString *)url index:(NSNumber *)index {
  ThrioPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (route) {
    route.prev.next = nil;
    [self thrio_onNotify];
  }
}

- (void)thrio_didPopToUrl:(NSString *)url index:(NSNumber *)index {
  ThrioPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (route) {
    route.next = nil;
    [self thrio_onNotify];
  }
}

- (void)thrio_didRemoveUrl:(NSString *)url index:(NSNumber *)index {
  ThrioPageRoute *route = [self thrio_getRouteByUrl:url index:index];
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

- (ThrioPageRoute * _Nullable)thrio_getRouteByUrl:(NSString *)url index:(NSNumber *)index {
  ThrioPageRoute *last = self.thrio_lastRoute;
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
  ThrioPageRoute *route = [self thrio_getRouteByUrl:url index:@0];
  return route ? route.settings.index : @0;
}

- (NSArray *)thrio_getAllIndexByUrl:(NSString *)url {
  NSMutableArray *indexs = [NSMutableArray array];
  ThrioPageRoute *first = self.thrio_firstRoute;
  do {
    if ([first.settings.url isEqualToString:url]) {
      [indexs addObject:first.settings.index];
    }
  } while ((first = first.next));
  return [indexs copy];
}

- (void)thrio_setPopDisabled:(BOOL)disabled {
  [self thrio_setPopDisabledUrl:@"" index:@0 disabled:disabled];
}

- (void)thrio_setPopDisabledUrl:(NSString *)url
                          index:(NSNumber *)index
                       disabled:(BOOL)disabled {
  ThrioPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  route.popDisabled = disabled;
  
  NSMutableDictionary *arguments =
    [NSMutableDictionary dictionaryWithDictionary:[route.settings toArgumentsWithoutParams]];
  [arguments setObject:[NSNumber numberWithBool:disabled] forKey:@"disabled"];

  if (route != self.thrio_firstRoute && [self isKindOfClass:ThrioFlutterViewController.class]) {
    [[ThrioApp.shared channel] invokeMethod:@"__onSetPopDisabled__"
                                  arguments:arguments];
  }
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
  
  if (![self isKindOfClass:ThrioFlutterViewController.class]) {
    // 当页面出现后，给页面发送通知
    [self thrio_onNotify];
    
    if (self.thrio_hidesNavigationBar == nil) {
      self.thrio_hidesNavigationBar = @(self.navigationController.navigationBarHidden);
    }
    if (self.thrio_lastRoute.popDisabled) {
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
  BOOL isFlutterViewController = [self isKindOfClass:ThrioFlutterViewController.class];
  NSArray *keys = [self.thrio_lastRoute.notifications.allKeys copy];
  for (NSString *name in keys) {
    NSDictionary * params = [self.thrio_lastRoute removeNotify:name];
    if (isFlutterViewController) {
      NSDictionary *arguments = @{
        @"url": self.thrio_lastRoute.settings.url,
        @"index": self.thrio_lastRoute.settings.index,
        @"name": name,
        @"params": params,
      };
      [[ThrioApp.shared channel] sendEvent:@"__onNotify__" arguments:arguments];
    } else {
      if ([self conformsToProtocol:@protocol(ThrioNotifyProtocol)]) {
        [(id<ThrioNotifyProtocol>)self onNotify:name params:params];
      }
    }
  }
}

@end

NS_ASSUME_NONNULL_END
