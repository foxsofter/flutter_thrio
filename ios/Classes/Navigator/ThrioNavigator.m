//
//  ThrioNavigator.m
//  ThrioNavigator
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioNavigator.h"
#import "UIViewController+ThrioPageRoute.h"
#import "ThrioChannel.h"
#import "ThrioRegistrySet.h"
#import "ThrioApp.h"
#import "UINavigationController+ThrioNavigator.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ThrioNavigator

+ (instancetype)shared {
  static ThrioNavigator *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [ThrioNavigator new];
  });
  return instance;
}

#pragma mark - push methods

- (void)pushUrl:(NSString *)url {
  [ThrioApp.shared pushUrl:url params:@{} animated:YES result:^(BOOL result){}];
}

- (void)pushUrl:(NSString *)url
         result:(ThrioBoolCallback)result {
  [ThrioApp.shared pushUrl:url params:@{} animated:YES result:result];
}

- (void)pushUrl:(NSString *)url
       animated:(BOOL)animated {
  [ThrioApp.shared pushUrl:url params:@{} animated:animated result:^(BOOL result){}];
}

- (void)pushUrl:(NSString *)url
       animated:(BOOL)animated
         result:(ThrioBoolCallback)result {
  [ThrioApp.shared pushUrl:url params:@{} animated:animated result:result];
}

- (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params {
  [ThrioApp.shared pushUrl:url params:params animated:YES result:^(BOOL result){}];
}

- (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params
         result:(ThrioBoolCallback)result {
  [ThrioApp.shared pushUrl:url params:params animated:YES result:result];
}

- (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params
       animated:(BOOL)animated {
  [ThrioApp.shared pushUrl:url params:params animated:YES result:^(BOOL result){}];
}

- (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params
       animated:(BOOL)animated
         result:(ThrioBoolCallback)result {
  [ThrioApp.shared pushUrl:url params:params animated:YES result:result];
}

#pragma mark - notify methods

- (void)notifyUrl:(NSString *)url name:(NSString *)name {
  [ThrioApp.shared notifyUrl:url index:@0 name:name params:@{} result:^(BOOL result){}];
}

- (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           result:(ThrioBoolCallback)result {
  [ThrioApp.shared notifyUrl:url index:@0 name:name params:@{} result:result];
}

- (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name {
  [ThrioApp.shared notifyUrl:url index:index name:name params:@{} result:^(BOOL result){}];
}

- (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           result:(ThrioBoolCallback)result {
  [ThrioApp.shared notifyUrl:url index:index name:name params:@{} result:result];
}

- (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           params:(NSDictionary *)params {
  [ThrioApp.shared notifyUrl:url index:@0 name:name params:params result:^(BOOL result){}];
}

- (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           params:(NSDictionary *)params
           result:(ThrioBoolCallback)result {
  [ThrioApp.shared notifyUrl:url index:@0 name:name params:params result:result];
}

- (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           params:(NSDictionary *)params {
  [ThrioApp.shared notifyUrl:url index:index name:name params:params result:^(BOOL result){}];
}

- (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           params:(NSDictionary *)params
           result:(ThrioBoolCallback)result {
  [ThrioApp.shared notifyUrl:url index:index name:name params:params result:result];
}

#pragma mark - pop methods

- (void)pop {
  [ThrioApp.shared popAnimated:YES result:^(BOOL result){}];
}

- (void)popAnimated:(BOOL)animated {
  [ThrioApp.shared popAnimated:animated result:^(BOOL result){}];
}

- (void)popAnimated:(BOOL)animated result:(ThrioBoolCallback)result {
  [ThrioApp.shared popAnimated:animated result:result];
}

#pragma mark - popTo methods

- (void)popToUrl:(NSString *)url {
  [ThrioApp.shared popToUrl:url index:@0 animated:YES result:^(BOOL result){}];
}

- (void)popToUrl:(NSString *)url
          result:(ThrioBoolCallback)result {
  [ThrioApp.shared popToUrl:url index:@0 animated:YES result:result];
}

- (void)popToUrl:(NSString *)url
           index:(NSNumber *)index {
  [ThrioApp.shared popToUrl:url index:index animated:YES result:^(BOOL result){}];
}

- (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
          result:(ThrioBoolCallback)result {
  [ThrioApp.shared popToUrl:url index:index animated:YES result:result];
}

- (void)popToUrl:(NSString *)url
        animated:(BOOL)animated {
  [ThrioApp.shared popToUrl:url index:@0 animated:animated result:^(BOOL result){}];
}

- (void)popToUrl:(NSString *)url
        animated:(BOOL)animated
          result:(ThrioBoolCallback)result {
  [ThrioApp.shared popToUrl:url index:@0 animated:animated result:result];
}

- (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
        animated:(BOOL)animated {
  [ThrioApp.shared popToUrl:url index:@0 animated:animated result:^(BOOL result){}];
}

- (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
        animated:(BOOL)animated
          result:(ThrioBoolCallback)result {
  [ThrioApp.shared popToUrl:url index:index animated:animated result:result];
}

#pragma mark - remove methods

- (void)removeUrl:(NSString *)url {
  [ThrioApp.shared removeUrl:url index:@0 animated:YES result:^(BOOL result){}];
}

- (void)removeUrl:(NSString *)url
     result:(ThrioBoolCallback)result {
  [ThrioApp.shared removeUrl:url index:@0 animated:YES result:result];
}

- (void)removeUrl:(NSString *)url
      index:(NSNumber *)index {
  [ThrioApp.shared removeUrl:url index:index animated:YES result:^(BOOL result){}];
}

- (void)removeUrl:(NSString *)url
      index:(NSNumber *)index
     result:(ThrioBoolCallback)result {
  [ThrioApp.shared removeUrl:url index:index animated:YES result:result];
}

- (void)removeUrl:(NSString *)url
   animated:(BOOL)animated {
  [ThrioApp.shared removeUrl:url index:@0 animated:animated result:^(BOOL result){}];
}

- (void)removeUrl:(NSString *)url
   animated:(BOOL)animated
     result:(ThrioBoolCallback)result {
  [ThrioApp.shared removeUrl:url index:@0 animated:animated result:result];
}

- (void)removeUrl:(NSString *)url
      index:(NSNumber *)index
   animated:(BOOL)animated {
  [ThrioApp.shared removeUrl:url index:@0 animated:animated result:^(BOOL result){}];
}

- (void)removeUrl:(NSString *)url
            index:(NSNumber *)index
         animated:(BOOL)animated
           result:(ThrioBoolCallback)result {
  [ThrioApp.shared removeUrl:url index:@0 animated:animated result:result];
}

#pragma mark - predicate methods

- (BOOL)canNotifyUrl:(NSString *)url index:(NSNumber * _Nullable)index {
  return [ThrioApp.shared canNotifyUrl:url index:index];
}

- (BOOL)canPop {
  return [ThrioApp.shared canPop];
}

- (BOOL)canRemoveUrl:(NSString *)url index:(NSNumber * _Nullable)index {
  return [ThrioApp.shared canRemoveUrl:url index:index];
}

- (BOOL)canPopToUrl:(NSString *)url index:(NSNumber * _Nullable)index {
  return [ThrioApp.shared canPopToUrl:url index:index];
}

- (BOOL)canPushUrl:(NSString *)url params:(NSDictionary * _Nullable)params {
  return [ThrioApp.shared canPushUrl:url params:params];
}

#pragma mark - get index methods

- (NSNumber *)lastIndex {
  return [ThrioApp.shared lastIndex];
}

- (NSNumber *)getLastIndexByUrl:(NSString *)url {
  return [ThrioApp.shared getLastIndexByUrl:url];
}

- (NSArray *)getAllIndexByUrl:(NSString *)url {
  return [ThrioApp.shared getAllIndexByUrl:url];
}

- (void)setPopDisabledUrl:(NSString *)url index:(NSNumber *)index disabled:(BOOL)disabled {
  return [ThrioApp.shared setPopDisabledUrl:url index:index disabled:disabled];
}

@end

NS_ASSUME_NONNULL_END
