//
//  ThrioRouter.m
//  thrio_router
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioRouter.h"
#import "ThrioRouterChannel.h"
#import "Category/UIApplication+ThrioRouter.h"
#import "Category/UINavigationController+ThrioRouter.h"
#import "Category/UIViewController+ThrioRouter.h"
#import "Registry/ThrioRegistryMap.h"
#import "Registry/ThrioRegistrySet.h"

@interface ThrioRouter ()

@property (nonatomic, strong, readwrite) NSObject<FlutterPluginRegistrar> *registarar;

@property (nonatomic, strong) ThrioRegistryMap *pageBuilders;

@property (nonatomic, strong) ThrioRegistrySet *predicates;

@end

@implementation ThrioRouter {
  __weak UINavigationController *_navigationController;
}

static ThrioRouter *instance;

+ (instancetype)router {
  return instance;
}

+ (instancetype)router:(NSObject<FlutterPluginRegistrar> *)registrar {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [ThrioRouter new];
  });
  if (registrar) {
    instance.registarar = registrar;
  }
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
    canNotify = [self.navigationController thrio_notifyPageWithName:name
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
    ThrioPageBuilder builder = _pageBuilders[url];
    if (builder) {
      UIViewController *vc = builder(params);
      if (vc) {
        [vc thrio_setUrl:url params:params];
        [self.navigationController pushViewController:vc animated:animated];
        canPush = YES;
      } else {
        canPush = NO;
      }
    } else {
      
    }
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
    canPop = [self.navigationController thrio_popPageWithUrl:url
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
    canPopTo = [self.navigationController thrio_popToPageWithUrl:url
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
  return [_pageBuilders registry:url value:builder];
}

- (ThrioVoidCallback)registryPredicate:(ThrioRouterPredicate *)predicate {
  return [_predicates registry:predicate];
}

#pragma mark - private predicate methods

- (BOOL)canNotify:(NSString *)url
            index:(nullable NSNumber *)index
           params:(nullable NSDictionary *)params {
  BOOL canNotify = [self.navigationController thrio_containsPageWithUrl:url
                                                                  index:index];
  if (!canNotify) {
    return NO;
  }
  NSSet *predicates = _predicates.values;
  for (ThrioNotifyPredicate it in predicates) {
    BOOL result = it(url, index, params);
    if (canNotify) {
      canNotify = result;
    }
  }
  return canNotify;
}

- (BOOL)canPop:(NSString *)url index:(nullable NSNumber *)index {
  BOOL canPop = [self.navigationController thrio_containsPageWithUrl:url
                                                               index:index];
  if (!canPop) {
    return NO;
  }
  NSSet *predicates = _predicates.values;
  for (ThrioPopPredicate it in predicates) {
    BOOL result = it(url, index);
    if (canPop) {
      canPop = result;
    }
  }
  return canPop;
}

- (BOOL)canPopTo:(NSString *)url index:(nullable NSNumber *)index {
  BOOL canPopTo = [self.navigationController thrio_containsPageWithUrl:url
                                                                 index:index];
  if (!canPopTo) {
    return NO;
  }
  NSSet *predicates = _predicates.values;
  for (ThrioPopToPredicate it in predicates) {
    BOOL result = it(url, index);
    if (canPopTo) {
      canPopTo = result;
    }
  }
  return canPopTo;
}

- (BOOL)canPush:(NSString *)url
         params:(nullable NSDictionary *)params {
  BOOL canPush = self.navigationController != nil;
  if (!canPush) {
    return NO;
  }
  NSSet *predicates = _predicates.values;
  for (ThrioPushPredicate it in predicates) {
    BOOL result = it(url, params);
    if (canPush) {
      canPush = result;
    }
  }
  return canPush;
}

@end
