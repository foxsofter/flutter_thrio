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

NS_ASSUME_NONNULL_BEGIN

@implementation UIViewController (ThrioPage)

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
  NSNumber *currentIndex = [[ThrioApp.shared topmostPage] pageIndex];
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

@end

NS_ASSUME_NONNULL_END
