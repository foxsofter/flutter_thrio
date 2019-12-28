//
//  ThrioRouter.m
//  ThrioRouter
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioRouter.h"
#import "UIViewController+ThrioPage.h"
#import "ThrioChannel.h"
#import "ThrioRegistrySet.h"
#import "ThrioApp.h"
#import "UINavigationController+ThrioRouter.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ThrioRouter

+ (instancetype)shared {
  static ThrioRouter *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [ThrioRouter new];
  });
  return instance;
}

#pragma mark - notify methods

- (void)notify:(NSString *)name
           url:(NSString *)url {
  [ThrioApp.shared notify:name url:url index:@0 params:@{} result:^(BOOL result){}];
}

- (void)notify:(NSString *)name
           url:(NSString *)url
        result:(ThrioBoolCallback)result {
  [ThrioApp.shared notify:name url:url index:@0 params:@{} result:result];
}

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index {
  [ThrioApp.shared notify:name url:url index:index params:@{} result:^(BOOL result){}];
}

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index
        result:(ThrioBoolCallback)result {
  [ThrioApp.shared notify:name url:url index:index params:@{} result:result];
}

- (void)notify:(NSString *)name
           url:(NSString *)url
        params:(NSDictionary *)params {
  [ThrioApp.shared notify:name url:url index:@0 params:params result:^(BOOL result){}];
}

- (void)notify:(NSString *)name
           url:(NSString *)url
        params:(NSDictionary *)params
        result:(ThrioBoolCallback)result {
  [ThrioApp.shared notify:name url:url index:@0 params:params result:result];
}

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index
        params:(NSDictionary *)params {
  [ThrioApp.shared notify:name url:url index:index params:params result:^(BOOL result){}];
}

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index
        params:(NSDictionary *)params
        result:(ThrioBoolCallback)result {
  [ThrioApp.shared notify:name url:url index:index params:params result:result];
}

#pragma mark - push methods

- (void)push:(NSString *)url {
  [ThrioApp.shared push:url params:@{} animated:YES result:^(BOOL result){}];
}

- (void)push:(NSString *)url
      result:(ThrioBoolCallback)result {
  [ThrioApp.shared push:url params:@{} animated:YES result:result];
}

- (void)push:(NSString *)url
    animated:(BOOL)animated {
  [ThrioApp.shared push:url params:@{} animated:animated result:^(BOOL result){}];
}

- (void)push:(NSString *)url
    animated:(BOOL)animated
      result:(ThrioBoolCallback)result {
  [ThrioApp.shared push:url params:@{} animated:animated result:result];
}

- (void)push:(NSString *)url
      params:(NSDictionary *)params {
  [ThrioApp.shared push:url params:params animated:YES result:^(BOOL result){}];
}

- (void)push:(NSString *)url
      params:(NSDictionary *)params
      result:(ThrioBoolCallback)result {
  [ThrioApp.shared push:url params:params animated:YES result:result];
}

- (void)push:(NSString *)url
      params:(NSDictionary *)params
    animated:(BOOL)animated {
  [ThrioApp.shared push:url params:params animated:YES result:^(BOOL result){}];
}

- (void)push:(NSString *)url
      params:(NSDictionary *)params
    animated:(BOOL)animated
      result:(ThrioBoolCallback)result {
  [ThrioApp.shared push:url params:params animated:YES result:result];
}

#pragma mark - pop methods

- (void)pop:(NSString *)url {
  [ThrioApp.shared pop:url index:@0 animated:YES result:^(BOOL result){}];
}

- (void)pop:(NSString *)url
     result:(ThrioBoolCallback)result {
  [ThrioApp.shared pop:url index:@0 animated:YES result:result];
}

- (void)pop:(NSString *)url
      index:(NSNumber *)index {
  [ThrioApp.shared pop:url index:index animated:YES result:^(BOOL result){}];
}

- (void)pop:(NSString *)url
      index:(NSNumber *)index
     result:(ThrioBoolCallback)result {
  [ThrioApp.shared pop:url index:index animated:YES result:result];
}

- (void)pop:(NSString *)url
   animated:(BOOL)animated {
  [ThrioApp.shared pop:url index:@0 animated:animated result:^(BOOL result){}];
}

- (void)pop:(NSString *)url
   animated:(BOOL)animated
     result:(ThrioBoolCallback)result {
  [ThrioApp.shared pop:url index:@0 animated:animated result:result];
}

- (void)pop:(NSString *)url
      index:(NSNumber *)index
   animated:(BOOL)animated {
  [ThrioApp.shared pop:url index:@0 animated:animated result:^(BOOL result){}];
}

- (void)pop:(NSString *)url
      index:(NSNumber *)index
   animated:(BOOL)animated
     result:(ThrioBoolCallback)result {
  [ThrioApp.shared pop:url index:@0 animated:animated result:result];
}

#pragma mark - popTo methods

- (void)popTo:(NSString *)url {
  [ThrioApp.shared popTo:url index:@0 animated:YES result:^(BOOL result){}];
}

- (void)popTo:(NSString *)url
       result:(ThrioBoolCallback)result {
  [ThrioApp.shared popTo:url index:@0 animated:YES result:result];
}

- (void)popTo:(NSString *)url
        index:(NSNumber *)index {
  [ThrioApp.shared popTo:url index:index animated:YES result:^(BOOL result){}];
}

- (void)popTo:(NSString *)url
        index:(NSNumber *)index
       result:(ThrioBoolCallback)result {
  [ThrioApp.shared popTo:url index:index animated:YES result:result];
}

- (void)popTo:(NSString *)url
     animated:(BOOL)animated {
  [ThrioApp.shared popTo:url index:@0 animated:animated result:^(BOOL result){}];
}

- (void)popTo:(NSString *)url
     animated:(BOOL)animated
       result:(ThrioBoolCallback)result {
  [ThrioApp.shared popTo:url index:@0 animated:animated result:result];
}

- (void)popTo:(NSString *)url
        index:(NSNumber *)index
     animated:(BOOL)animated {
  [ThrioApp.shared popTo:url index:@0 animated:animated result:^(BOOL result){}];
}

- (void)popTo:(NSString *)url
        index:(NSNumber *)index
     animated:(BOOL)animated
       result:(ThrioBoolCallback)result {
  [ThrioApp.shared popTo:url index:index animated:animated result:result];
}

#pragma mark - predicate methods

- (BOOL)canNotify:(NSString *)url index:(nullable NSNumber *)index {
  return [ThrioApp.shared canNotify:url index:index];
}

- (BOOL)canPop:(NSString *)url index:(nullable NSNumber *)index {
  return [ThrioApp.shared canPop:url index:index];
}

- (BOOL)canPopTo:(NSString *)url index:(nullable NSNumber *)index {
  return [ThrioApp.shared canPopTo:url index:index];
}

- (BOOL)canPush:(NSString *)url params:(nullable NSDictionary *)params {
  return [ThrioApp.shared canPush:url params:params];
}

@end

NS_ASSUME_NONNULL_END
