//
//  UIViewController+ThrioPage.m
//  thrio
//
//  Created by foxsofter on 2019/12/16.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "UINavigationController+ThrioRouter.h"
#import "UIViewController+ThrioPage.h"
#import "ThrioApp.h"
#import "ThrioLogger.h"
#import "ThrioFlutterPage.h"
#import "NSObject+ThrioSwizzling.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIViewController (ThrioPage)

- (NSDictionary *)pageArguments {
  return @{
    @"url": self.pageUrl,
    @"index": self.pageIndex,
    @"params": self.pageParams,
  };
}

#pragma mark - ThrioPageProtocol methods

- (NSString *)pageUrl {
  return objc_getAssociatedObject(self, @selector(setPageUrl:));
}

- (void)setPageUrl:(NSString *)url {
  NSAssert(url && url.length > 0, @"url must not be null or empty.");
  if ([self pageUrl]) {
    ThrioLogV(@"url is already set.");
    return;
  }
  
  ThrioLogV(@"url is %@", url);
  objc_setAssociatedObject(self,
                           @selector(setPageUrl:),
                           url,
                           OBJC_ASSOCIATION_COPY_NONATOMIC);
  
  NSNumber *index = @1;
  NSNumber *currentIndex = [ThrioApp.shared topmostPageIndexWithUrl:url];
  if (currentIndex) {
    index = @(currentIndex.integerValue + 1);
  }
  [self setPageIndex:index];
}

- (NSNumber *)pageIndex {
  return objc_getAssociatedObject(self, @selector(setPageIndex:));
}

- (void)setPageIndex:(NSNumber *)index {
  objc_setAssociatedObject(self,
                           @selector(setPageIndex:),
                           index,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  if ([self isKindOfClass:ThrioFlutterPage.class]) {
    [(ThrioFlutterPage *)self sendPageLifecycleEvent:ThrioPageLifecycleInited];
  }
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

- (NSDictionary *)pageParams {
  return objc_getAssociatedObject(self, @selector(setPageParams:));
}

- (void)setPageParams:(NSDictionary *)params {
  objc_setAssociatedObject(self,
                           @selector(setPageParams:),
                           params,
                           OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *)pageNotifications {
  return objc_getAssociatedObject(self, @selector(setPageNotifications:));
}

- (void)setPageNotifications:(NSDictionary *)notifications {
  objc_setAssociatedObject(self,
                           @selector(setPageNotifications:),
                           notifications,
                           OBJC_ASSOCIATION_COPY_NONATOMIC);
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
  
  // 原生页面，当页面出现后，记录navigationBarHidden的值
  if (![self isKindOfClass:ThrioFlutterPage.class]) {
    self.hidesNavigationBarWhenPushed = self.navigationController.navigationBarHidden;
  }

  // 当页面出现后，给页面发送通知
  if ([self conformsToProtocol:@protocol(ThrioNotifyProtocol)] &&
      [self.pageNotifications count] > 0) {
    NSArray *keys = [self.pageNotifications.allKeys copy];
    for (id name in keys) {
      [(id<ThrioNotifyProtocol>)self onNotifyWithName:name
                                               params:self.pageNotifications[name]];
    }
  }
}

@end

NS_ASSUME_NONNULL_END
