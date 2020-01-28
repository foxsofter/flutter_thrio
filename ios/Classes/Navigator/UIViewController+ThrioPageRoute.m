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

@property (nonatomic, strong, readwrite, nullable) ThrioPageRoute *firstRoute;

@end

@implementation UIViewController (ThrioPageRoute)

- (ThrioWillPopCallback _Nullable)willPopCallback {
  return objc_getAssociatedObject(self, @selector(setWillPopCallback:));
}

- (void)setWillPopCallback:(ThrioWillPopCallback _Nullable)callback {
  objc_setAssociatedObject(self,
                           @selector(setWillPopCallback:),
                           callback,
                           OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSNumber * _Nullable)hidesNavigationBarWhenPushed {
  return objc_getAssociatedObject(self, @selector(setHidesNavigationBarWhenPushed:));
}

- (void)setHidesNavigationBarWhenPushed:(NSNumber * _Nullable)hidesNavigationBarWhenPushed {
  objc_setAssociatedObject(self,
                           @selector(setHidesNavigationBarWhenPushed:),
                           hidesNavigationBarWhenPushed,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ThrioPageRoute * _Nullable)firstRoute {
  return objc_getAssociatedObject(self, @selector(setFirstRoute:));
}

- (void)setFirstRoute:(ThrioPageRoute * _Nullable)route {
  objc_setAssociatedObject(self,
                           @selector(setFirstRoute:),
                           route,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ThrioPageRoute * _Nullable)lastRoute {
  ThrioPageRoute *next = self.firstRoute;
  while (next.next) {
    next = next.next;
  }
  return next;
}

- (void)thrio_pushUrl:(NSString *)url
               params:(NSDictionary *)params
             animated:(BOOL)animated
               result:(ThrioBoolCallback)result{
  NSNumber *index = @([self thrio_getLastIndexByUrl:url].integerValue + 1);
  ThrioRouteSettings *settings = [ThrioRouteSettings settingsWithUrl:url
                                                               index:index
                                                              nested:self.firstRoute != nil
                                                              params:params];
  ThrioPageRoute *newRoute = [ThrioPageRoute routeWithSettings:settings];
  if (self.firstRoute) {
    ThrioPageRoute *lastRoute = self.lastRoute;
    lastRoute.next = newRoute;
    newRoute.prev = lastRoute;
  } else {
    self.firstRoute = newRoute;
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
  ThrioPageRoute *route = self.lastRoute;
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
        if (route != strongSelf.firstRoute) {
          route.prev.next = nil;
          [strongSelf thrio_onNotify];
        } else {
          strongSelf.firstRoute = nil;
        }
      }
      result([r boolValue]);
    }];
  } else {
    if (route != self.firstRoute) {
      route.prev.next = nil;
      [self thrio_onNotify];
    } else {
      self.firstRoute = nil;
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
        if (route == strongSelf.firstRoute) {
          strongSelf.firstRoute = route.next;
          strongSelf.firstRoute.prev = nil;
        } else if (route == self.lastRoute) {
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
    if (route == self.firstRoute) {
      self.firstRoute = route.next;
      self.firstRoute.prev = nil;
    } else if (route == self.lastRoute) {
      route.prev.next = nil;
      [self thrio_onNotify];
    } else {
      route.prev.next = route.next;
      route.next.prev = route.prev;
    }
    result(YES);
  }
}

- (ThrioPageRoute * _Nullable)thrio_getRouteByUrl:(NSString *)url index:(NSNumber *)index {
  ThrioPageRoute *last = self.lastRoute;
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
  ThrioPageRoute *first = self.firstRoute;
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
  });
}

- (void)thrio_viewDidAppear:(BOOL)animated {
  [self thrio_viewDidAppear:animated];
  
  if (![self isKindOfClass:ThrioFlutterViewController.class]) {
    // 当页面出现后，给页面发送通知
    [self thrio_onNotify];
    
    if (self.hidesNavigationBarWhenPushed == nil) {
      self.hidesNavigationBarWhenPushed = @(self.navigationController.navigationBarHidden);
    }
  }
  if (self.hidesNavigationBarWhenPushed.boolValue != self.navigationController.navigationBarHidden) {
    self.navigationController.navigationBarHidden = self.hidesNavigationBarWhenPushed.boolValue;
  }
}

- (void)thrio_onNotify {
  BOOL isFlutterViewController = [self isKindOfClass:ThrioFlutterViewController.class];
  NSArray *keys = [self.lastRoute.notifications.allKeys copy];
  for (NSString *name in keys) {
    NSDictionary * params = [self.lastRoute removeNotify:name];
    if (isFlutterViewController) {
      NSDictionary *arguments = @{
        @"url": self.lastRoute.settings.url,
        @"index": self.lastRoute.settings.index,
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
