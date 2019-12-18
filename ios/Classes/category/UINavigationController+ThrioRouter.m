//
//  UINavigationController+ThrioRouter.m
//  thrio_router
//
//  Created by Wei ZhongDan on 2019/12/17.
//

#import "UINavigationController+ThrioRouter.h"
#import "UIViewController+ThrioRouter.h"
#import "ThrioRouterNotifyProtocol.h"

@implementation UINavigationController (ThrioRouter)

#pragma mark - ThrioRouterPageProtocol methods

- (NSNumber *)thrio_latestPageIndexOfUrl:(NSString *)url {
  UIViewController *vc = [self thrio_getPageWithUrl:url index:nil];
  return vc.thrio_index;
}

- (NSArray *)thrio_allPageIndexOfUrl:(NSString *)url {
  NSArray *vcs = self.viewControllers;
  NSMutableArray *indexs = [NSMutableArray array];
  for (UIViewController *vc in vcs) {
    if ([vc.thrio_url isEqualToString:url]) {
      [indexs addObject:vc.thrio_index];
    }
  }
  return indexs;
}

- (BOOL)thrio_containsPageWithUrl:(NSString *)url {
  return [self thrio_getPageWithUrl:url index:nil] != nil;
}

- (BOOL)thrio_containsPageWithUrl:(NSString *)url
                            index:(NSNumber *)index {
  return [self thrio_getPageWithUrl:url index:index] != nil;
}

- (BOOL)thrio_notifyPageWithName:(NSString *)name
                             url:(NSString *)url
                           index:(NSNumber *)index
                          params:(NSDictionary *)params {
  UIViewController *vc = [self thrio_getPageWithUrl:url index:index];
  if ([vc conformsToProtocol:@protocol(ThrioRouterNotifyProtocol)]) {
    if (!vc.thrio_notifications) {
      vc.thrio_notifications = [NSMutableDictionary dictionary];
    }
    [vc.thrio_notifications setValue:params ? params : @{} forKey:name];
    return YES;
  }
  return NO;
}

- (BOOL)thrio_popPageWithUrl:(NSString *)url
                       index:(NSNumber *)index
                    animated:(BOOL)animated {
  UIViewController *vc = [self thrio_getPageWithUrl:url index:index];
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

- (BOOL)thrio_popToPageWithUrl:(NSString *)url
                         index:(NSNumber *)index
                      animated:(BOOL)animated {
  UIViewController *vc = [self thrio_getPageWithUrl:url index:index];
  if (!vc || vc == self.topViewController) {
    return NO;
  }
  [self popToViewController:vc animated:animated];
  return YES;
}

#pragma mark - UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
  if ([viewController conformsToProtocol:@protocol(ThrioRouterNotifyProtocol)] &&
      [viewController.thrio_notifications count] > 0) {
    NSDictionary *notifications = [viewController.thrio_notifications copy];
    for (id name in notifications.allKeys) {
      [(id)viewController onNotifyWithName:name
                                    params:notifications[name]];
    }
  }
}


#pragma mark - helper methods

- (UIViewController *)thrio_getPageWithUrl:(NSString *)url
                                     index:(NSNumber *)index {
  NSEnumerator *vcs = [self.viewControllers reverseObjectEnumerator];
  if (index && index.integerValue > 0) {
    for (UIViewController *vc in vcs) {
      if ([vc.thrio_url isEqualToString:url] &&
          [vc.thrio_index isEqualToNumber:index]) {
        return vc;
      }
    }
  } else {
    for (UIViewController *vc in vcs) {
      if ([vc.thrio_url isEqualToString:url]) {
        return vc;
      }
    }
  }
  return nil;
}

@end
