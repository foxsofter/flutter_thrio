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

@property (nonatomic, strong, readwrite) ThrioPageRoute *firstRoute;

@end

@implementation UIViewController (ThrioPageRoute)

- (ThrioPageRoute *)firstRoute {
  return objc_getAssociatedObject(self, @selector(setFirstRoute:));
}

- (void)setFirstRoute:(ThrioPageRoute *)route {
  if ([self firstRoute]) {
    ThrioLogV(@"route is already set.");
    return;
  }

  ThrioLogV(@"route setting: %@", route.settings);
  objc_setAssociatedObject(self,
                           @selector(setFirstRoute:),
                           route,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hidesNavigationBarWhenPushed {
  return [(NSNumber *)objc_getAssociatedObject(self, @selector(setHidesNavigationBarWhenPushed:)) boolValue];
}

- (void)setHidesNavigationBarWhenPushed:(BOOL)hidesNavigationBarWhenPushed {
  objc_setAssociatedObject(self,
                           @selector(setHidesNavigationBarWhenPushed:),
                           @(hidesNavigationBarWhenPushed),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ThrioPageRoute *)lastRoute {
  ThrioPageRoute *next = self.firstRoute;
  while (next.next) {
    next = next.next;
  }
  return next;
}

- (void)thrio_pushUrl:(NSString *)url
               params:(NSDictionary *)params {
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
    [[ThrioApp.shared channel] invokeMethod:@"__onPush__"
                                  arguments:[settings toArguments]];
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


- (BOOL)thrio_popUrl:(NSString *)url index:(NSNumber *)index {
  ThrioPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (!route) {
    return NO;
  }
  if ([self isKindOfClass:ThrioFlutterViewController.class]) {
    NSDictionary *arguments = [route.settings toArgumentsWithoutParams];
    [[ThrioApp.shared channel] invokeMethod:@"__onPop__" arguments:arguments];
  }
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
  return YES;
}

- (BOOL)thrio_popToUrl:(NSString *)url index:(NSNumber *)index {
  ThrioPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  if (!route) {
    return NO;
  }
  if ([self isKindOfClass:ThrioFlutterViewController.class]) {
    NSDictionary *arguments = [route.settings toArgumentsWithoutParams];
    [[ThrioApp.shared channel] invokeMethod:@"__onPopTo__" arguments:arguments];
  }
  route.next = nil;
  [self thrio_onNotify];
  return YES;
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

- (void)thrio_viewDidAppear:(BOOL)animated {
  [self thrio_viewDidAppear:animated];
  
  // 原生页面，当页面出现后，记录navigationBarHidden的值
  if (![self isKindOfClass:ThrioFlutterViewController.class]) {
    self.hidesNavigationBarWhenPushed = self.navigationController.navigationBarHidden;
    // 当页面出现后，给页面发送通知
    [self thrio_onNotify];
  }
}

@end

NS_ASSUME_NONNULL_END
