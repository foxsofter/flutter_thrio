//
//  UINavigationController+Thrio.m
//  thrio
//
//  Created by foxsofter on 2019/12/17.
//

#import <objc/runtime.h>
#import "UINavigationController+ThrioRouter.h"
#import "UIViewController+ThrioPage.h"
#import "ThrioNotifyProtocol.h"
#import "ThrioRegistryMap.h"
#import "ThrioFlutterPage.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UINavigationController (ThrioRouter)

#pragma mark - ThrioNavigationProtocol methods

- (BOOL)pushPageWithUrl:(NSString *)url
                 params:(NSDictionary *)params
               animated:(BOOL)animated {
  UIViewController *page;
  ThrioPageBuilder builder = [[self pageBuilders] valueForKey:url];
  if (builder) {
    page = builder(params);
  } else {
    page = [[ThrioFlutterPage alloc] init];
  }
  page.pageParams = page.pageParams ?: params ;
  page.pageUrl = url;
  [self.navigationController pushViewController:page animated:animated];
  return YES;
}

- (BOOL)notifyPageWithName:(NSString *)name
                       url:(NSString *)url
                     index:(NSNumber *)index
                    params:(NSDictionary *)params {
  UIViewController *vc = [self getPageWithUrl:url index:index];
  if ([vc conformsToProtocol:@protocol(ThrioNotifyProtocol)]) {
    if (!(vc.pageNotifications)) {
      vc.pageNotifications = [NSMutableDictionary dictionary];
    }
    [vc.pageNotifications setValue:params ? params : @{} forKey:name];
    return YES;
  }
  return NO;
}

- (BOOL)popPageWithUrl:(NSString *)url
                 index:(NSNumber *)index
              animated:(BOOL)animated {
  UIViewController *vc = [self getPageWithUrl:url index:index];
  if (!vc) {
    return NO;
  }
  if (vc == self.topViewController) {
    [self popViewControllerAnimated:animated];
  } else {
    NSMutableArray *vcs = [self.viewControllers mutableCopy];
    [vcs removeObject:vc];
    [self setViewControllers:vcs animated:animated];
  }
  return YES;
}

- (BOOL)popToPageWithUrl:(NSString *)url
                   index:(NSNumber *)index
                animated:(BOOL)animated {
  UIViewController *vc = [self getPageWithUrl:url index:index];
  if (!vc || vc == self.topViewController) {
    return NO;
  }
  [self popToViewController:vc animated:animated];
  return YES;
}

- (NSNumber *)latestPageIndexOfUrl:(NSString *)url {
  UIViewController *vc = [self getPageWithUrl:url index:@0];
  return vc.pageIndex;
}

- (NSArray *)allPageIndexOfUrl:(NSString *)url {
  NSArray *vcs = self.viewControllers;
  NSMutableArray *indexs = [NSMutableArray array];
  for (UIViewController *vc in vcs) {
    if ([vc.pageUrl isEqualToString:url]) {
      [indexs addObject:vc.pageIndex];
    }
  }
  return indexs;
}

- (BOOL)containsPageWithUrl:(NSString *)url {
  return [self getPageWithUrl:url index:@0] != nil;
}

- (BOOL)containsPageWithUrl:(NSString *)url index:(NSNumber *)index {
  return [self getPageWithUrl:url index:index] != nil;
}

- (ThrioVoidCallback)registryPageBuilder:(ThrioPageBuilder)builder
                                  forUrl:(NSString *)url {
  ThrioRegistryMap *pageBuilders = [self pageBuilders];
  if (!pageBuilders) {
    pageBuilders = [[ThrioRegistryMap alloc] init];
    [self setPageBuilders:pageBuilders];
  }
  return [pageBuilders registry:url value:builder];
}

#pragma mark - UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
  if ([viewController conformsToProtocol:@protocol(ThrioNotifyProtocol)] &&
      [viewController.pageNotifications count] > 0) {
    NSDictionary *notifications = [viewController.pageNotifications copy];
    for (id name in notifications.allKeys) {
      [(id)viewController onNotifyWithName:name
                                    params:notifications[name]];
    }
  }
}

#pragma mark - private methods

- (UIViewController *)getPageWithUrl:(NSString *)url
                               index:(NSNumber *)index {
  NSEnumerator *vcs = [self.viewControllers reverseObjectEnumerator];
  if (index && index.integerValue > 0) {
    for (UIViewController *vc in vcs) {
      if ([vc.pageUrl isEqualToString:url] &&
          [vc.pageIndex isEqualToNumber:index]) {
        return vc;
      }
    }
  } else {
    for (UIViewController *vc in vcs) {
      if ([vc.pageUrl isEqualToString:url]) {
        return vc;
      }
    }
  }
  return nil;
}

- (ThrioRegistryMap *)pageBuilders {
  return objc_getAssociatedObject(self, @selector(setPageBuilders:));
}

- (void)setPageBuilders:(ThrioRegistryMap *)builders {
    objc_setAssociatedObject(self,
                             @selector(setPageBuilders:),
                             builders,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

NS_ASSUME_NONNULL_END
