//
//  ThrioRouter.m
//  ThrioRouter
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioRouter.h"
#import "UINavigationController+ThrioRouter.h"
#import "UIViewController+ThrioPage.h"
#import "../Channel/ThrioChannel.h"
#import "../Category/UIApplication+Thrio.h"
#import "../Registry/ThrioRegistrySet.h"

@implementation ThrioRouter {
  __weak UINavigationController *_navigationController;
}

+ (instancetype)shared {
  static ThrioRouter *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [ThrioRouter new];
  });
  return instance;
}

#pragma mark - public properties

- (UINavigationController *)navigationController {
  UINavigationController *nvc = [[UIApplication sharedApplication] topmostNavigationController];
  if (_navigationController != nvc) {
    _navigationController = nvc;
    _navigationController.delegate = nvc;
  }
  return _navigationController;
}

#pragma mark - notify methods

- (void)notify:(NSString *)name
           url:(NSString *)url {
  [self notify:name url:url index:@0 params:@{} result:^(BOOL result){}];
}

- (void)notify:(NSString *)name
           url:(NSString *)url
        result:(ThrioBoolCallback)result {
  [self notify:name url:url index:@0 params:@{} result:result];
}

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index {
  [self notify:name url:url index:index params:@{} result:^(BOOL result){}];
}

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index
        result:(ThrioBoolCallback)result {
  [self notify:name url:url index:index params:@{} result:result];
}

- (void)notify:(NSString *)name
           url:(NSString *)url
        params:(NSDictionary *)params {
  [self notify:name url:url index:@0 params:params result:^(BOOL result){}];
}

- (void)notify:(NSString *)name
           url:(NSString *)url
        params:(NSDictionary *)params
        result:(ThrioBoolCallback)result {
  [self notify:name url:url index:@0 params:params result:result];
}

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index
        params:(NSDictionary *)params {
  [self notify:name url:url index:index params:params result:^(BOOL result){}];
}

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index
        params:(NSDictionary *)params
        result:(ThrioBoolCallback)result {
  BOOL canNotify = [self canNotify:url index:index params:params];
  if (canNotify) {
    canNotify = [self.navigationController notifyPageWithName:name
                                                          url:url
                                                        index:index
                                                       params:params];
  }
  if (result) {
    result(canNotify);
  }
}

#pragma mark - push methods

- (void)push:(NSString *)url {
  [self push:url params:@{} animated:YES result:^(BOOL result){}];
}

- (void)push:(NSString *)url
      result:(ThrioBoolCallback)result {
  [self push:url params:@{} animated:YES result:result];
}

- (void)push:(NSString *)url
    animated:(BOOL)animated {
  [self push:url params:@{} animated:animated result:^(BOOL result){}];
}

- (void)push:(NSString *)url
    animated:(BOOL)animated
      result:(ThrioBoolCallback)result {
  [self push:url params:@{} animated:animated result:result];
}

- (void)push:(NSString *)url
      params:(NSDictionary *)params {
  [self push:url params:params animated:YES];
}

- (void)push:(NSString *)url
      params:(NSDictionary *)params
      result:(ThrioBoolCallback)result {
  [self push:url params:params animated:YES result:result];
}

- (void)push:(NSString *)url
      params:(NSDictionary *)params
    animated:(BOOL)animated {
  [self push:url params:params animated:YES result:^(BOOL result){}];
}

- (void)push:(NSString *)url
      params:(NSDictionary *)params
    animated:(BOOL)animated
      result:(ThrioBoolCallback)result {
  BOOL canPush = [self canPush:url params:params];
  if (canPush) {
    canPush = [self.navigationController pushPageWithUrl:url
                                                  params:params
                                                animated:animated];
  }
  if (result) {
    result(canPush);
  }
}

#pragma mark - pop methods

- (void)pop:(NSString *)url {
  [self pop:url index:@0 animated:YES result:^(BOOL result){}];
}

- (void)pop:(NSString *)url
     result:(ThrioBoolCallback)result {
  [self pop:url index:@0 animated:YES result:result];
}

- (void)pop:(NSString *)url
      index:(NSNumber *)index {
  [self pop:url index:index animated:YES result:^(BOOL result){}];
}

- (void)pop:(NSString *)url
      index:(NSNumber *)index
     result:(ThrioBoolCallback)result {
  [self pop:url index:index animated:YES result:result];
}

- (void)pop:(NSString *)url
   animated:(BOOL)animated {
  [self pop:url index:@0 animated:animated result:^(BOOL result){}];
}

- (void)pop:(NSString *)url
   animated:(BOOL)animated
     result:(ThrioBoolCallback)result {
  [self pop:url index:@0 animated:animated result:result];
}

- (void)pop:(NSString *)url
      index:(NSNumber *)index
   animated:(BOOL)animated {
  [self pop:url index:@0 animated:animated result:^(BOOL result){}];
}

- (void)pop:(NSString *)url
      index:(NSNumber *)index
   animated:(BOOL)animated
     result:(ThrioBoolCallback)result {
  BOOL canPop = [self canPop:url index:index];
  if (canPop) {
    canPop = [self.navigationController popPageWithUrl:url
                                                 index:index
                                              animated:animated];
  }
  if (result) {
    result(canPop);
  }
}

#pragma mark - popTo methods

- (void)popTo:(NSString *)url {
  [self popTo:url index:@0 animated:YES result:^(BOOL result){}];
}

- (void)popTo:(NSString *)url
       result:(ThrioBoolCallback)result {
  [self popTo:url index:@0 animated:YES result:result];
}

- (void)popTo:(NSString *)url
        index:(NSNumber *)index {
  [self popTo:url index:index animated:YES result:^(BOOL result){}];
}

- (void)popTo:(NSString *)url
        index:(NSNumber *)index
       result:(ThrioBoolCallback)result {
  [self popTo:url index:index animated:YES result:result];
}

- (void)popTo:(NSString *)url
     animated:(BOOL)animated {
  [self popTo:url index:@0 animated:animated result:^(BOOL result){}];
}

- (void)popTo:(NSString *)url
     animated:(BOOL)animated
       result:(ThrioBoolCallback)result {
  [self popTo:url index:@0 animated:animated result:result];
}

- (void)popTo:(NSString *)url
        index:(NSNumber *)index
     animated:(BOOL)animated {
  [self popTo:url index:@0 animated:animated result:^(BOOL result){}];
}

- (void)popTo:(NSString *)url
        index:(NSNumber *)index
     animated:(BOOL)animated
       result:(ThrioBoolCallback)result {
  BOOL canPopTo = [self canPop:url index:index];
  if (canPopTo) {
    canPopTo = [self.navigationController popToPageWithUrl:url
                                                     index:index
                                                  animated:animated];
  }
  if (result) {
    result(canPopTo);
  }
}

#pragma mark - registry methods

- (ThrioVoidCallback)registryPage:(NSString *)url
                       forBuilder:(ThrioPageBuilder)builder {
  return [self.navigationController registryPageBuilder:builder forUrl:url];
}

#pragma mark - private predicate methods

- (BOOL)canNotify:(NSString *)url
            index:(nullable NSNumber *)index
           params:(nullable NSDictionary *)params {
  return [self.navigationController containsPageWithUrl:url
                                                  index:index];
}

- (BOOL)canPop:(NSString *)url index:(nullable NSNumber *)index {
  return [self.navigationController containsPageWithUrl:url
                                                  index:index];
}

- (BOOL)canPopTo:(NSString *)url index:(nullable NSNumber *)index {
  return [self.navigationController containsPageWithUrl:url
                                                  index:index];
}

- (BOOL)canPush:(NSString *)url
         params:(nullable NSDictionary *)params {
  return self.navigationController != nil;
}

@end
