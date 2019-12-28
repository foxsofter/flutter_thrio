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
  ThrioNativePageBuilder builder = [[self nativePageBuilders] valueForKey:url];
  if (builder) {
    page = builder(params);
  } else if ([self flutterPageBuilder]) {
    page = [self flutterPageBuilder]();
  } else {
    page = [[ThrioFlutterPage alloc] init];
  }
  page.pageParams = page.pageParams ?: params ;
  page.pageUrl = url;
  [self pushViewController:page animated:animated];
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

- (ThrioVoidCallback)registerNativePageBuilder:(ThrioNativePageBuilder)builder
                                        forUrl:(NSString *)url {
  ThrioRegistryMap *pageBuilders = [self nativePageBuilders];
  if (!pageBuilders) {
    pageBuilders = [[ThrioRegistryMap alloc] init];
    [self setNativePageBuilders:pageBuilders];
  }
  return [pageBuilders registry:url value:builder];
}

- (ThrioFlutterPageBuilder _Nullable)flutterPageBuilder {
  return objc_getAssociatedObject(self, @selector(setFlutterPageBuilder:));
}

- (void)setFlutterPageBuilder:(ThrioFlutterPageBuilder)builder {
  objc_setAssociatedObject(self,
                           @selector(setFlutterPageBuilder:),
                           builder,
                           OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
  if ([viewController conformsToProtocol:@protocol(ThrioNotifyProtocol)] &&
      [viewController.pageNotifications count] > 0) {
    NSArray *keys = [viewController.pageNotifications.allKeys copy];
    for (id name in keys) {
      [(id)viewController onNotifyWithName:name
                                    params:viewController.pageNotifications[name]];
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

- (ThrioRegistryMap *)nativePageBuilders {
  return objc_getAssociatedObject(self, @selector(setNativePageBuilders:));
}

- (void)setNativePageBuilders:(ThrioRegistryMap *)builders {
    objc_setAssociatedObject(self,
                             @selector(setNativePageBuilders:),
                             builders,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

NS_ASSUME_NONNULL_END
