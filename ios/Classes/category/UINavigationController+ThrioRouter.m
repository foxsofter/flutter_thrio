//
//  UINavigationController+ThrioRouter.m
//  thrio_router
//
//  Created by Wei ZhongDan on 2019/12/17.
//

#import "UINavigationController+ThrioRouter.h"
#import "UIViewController+ThrioRouter.h"

@implementation UINavigationController (ThrioRouter)

- (NSNumber *)thrio_latestPageIndexOfUrl:(NSString *)url {
  NSEnumerator *vcs = [self.viewControllers reverseObjectEnumerator];
  for (UIViewController *vc in vcs) {
    if ([vc.thrio_url isEqualToString:url]) {
      return vc.thrio_index;
    }
  }
  return nil;
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
  NSEnumerator *vcs = [self.viewControllers reverseObjectEnumerator];
  for (UIViewController *vc in vcs) {
    if ([vc.thrio_url isEqualToString:url]) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)thrio_containsPageWithUrl:(NSString *)url andIndex:(NSNumber *)index {
  NSEnumerator *vcs = [self.viewControllers reverseObjectEnumerator];
  
  if (index.integerValue > 0) {
    for (UIViewController *vc in vcs) {
      if ([vc.thrio_url isEqualToString:url] && [vc.thrio_index isEqualToNumber:index]) {
        return YES;
      }
    }
  } else {
    for (UIViewController *vc in vcs) {
      if ([vc.thrio_url isEqualToString:url]) {
        return YES;
      }
    }
  }
  return NO;
}

- (BOOL)thrio_pushPageWithUrl:(NSString *)url
                     animated:(BOOL)animated
                       params:(NSDictionary *)params {
  
}

- (BOOL)thrio_notifyPageWithName:(NSString *)name
                             url:(NSString *)url
                           index:(NSNumber *)index
                          params:(NSDictionary *)params {
  
}

- (BOOL)thrio_popPageWithUrl:(NSString *)url
                       index:(NSNumber *)index
                    animated:(BOOL)animated {
  
}

- (BOOL)thrio_popToPageWithUrl:(NSString *)url
                         index:(NSNumber *)index
                      animated:(BOOL)animated {
  
}

@end
