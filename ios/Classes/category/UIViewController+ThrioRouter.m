//
//  UIViewController+ThrioRouter.m
//  thrio_router
//
//  Created by Wei ZhongDan on 2019/12/16.
//

#import <objc/runtime.h>
#import "UINavigationController+ThrioRouter.h"
#import "UIViewController+ThrioRouter.h"
#import "../ThrioRouter.h"
#import "../ThrioRouterLogger.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIViewController (ThrioRouter)

#pragma mark - ThrioRouterContainerProtocol methods

- (NSString *)thrio_url {
  return objc_getAssociatedObject(self, @selector(setThrio_url:));
}

- (void)setThrio_url:(NSString *)url {
  objc_setAssociatedObject(self,
                           @selector(setThrio_url:),
                           url,
                           OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSNumber *)thrio_index {
  return objc_getAssociatedObject(self, @selector(setThrio_index:));
}

- (void)setThrio_index:(NSNumber *)index {
  objc_setAssociatedObject(self,
                           @selector(setThrio_index:),
                           index,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)thrio_params {
  return objc_getAssociatedObject(self, @selector(setThrio_params:));
}

- (void)setThrio_params:(nullable NSDictionary *)params {
    objc_setAssociatedObject(self,
                             @selector(setThrio_params:),
                             params,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *)thrio_notifications {
  return objc_getAssociatedObject(self, @selector(setThrio_notifications:));
}

- (void)setThrio_notifications:(NSDictionary *)notifications {
    objc_setAssociatedObject(self,
                             @selector(setThrio_notifications:),
                             notifications,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)thrio_setUrl:(NSString *)url
              params:(nullable NSDictionary *)params {
  NSAssert(url && url.length > 0, @"url must not be null or empty.");
  if ([self thrio_url]) {
    ThrioLogV(@"url is already set.");
    return;
  }
  
  [self setThrio_url:url];
  [self setThrio_params:params];
  NSNumber *index = @1;
  NSNumber *currentIndex = [[ThrioRouter.router navigationController] thrio_latestPageIndexOfUrl:url];
  if (currentIndex) {
    index = @(currentIndex.integerValue + 1);
  }
  [self setThrio_index:index];
}

@end

NS_ASSUME_NONNULL_END
