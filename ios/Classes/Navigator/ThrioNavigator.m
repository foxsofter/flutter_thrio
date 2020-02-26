//
//  ThrioNavigator.m
//  ThrioNavigator
//
//  Created by foxsofter on 2019/12/11.
//

#import <UIKit/UIKit.h>

#import "UIViewController+Navigator.h"
#import "ThrioRegistrySet.h"
#import "UINavigationController+Navigator.h"
#import "UINavigationController+PopGesture.h"
#import "UINavigationController+PopDisabled.h"
#import "ThrioNavigator.h"
#import "ThrioNavigator+NavigatorBuilder.h"
#import "ThrioNavigator+Internal.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ThrioNavigator

#pragma mark - push methods

+ (void)pushUrl:(NSString *)url {
  [self pushUrl:url params:@{} animated:YES result:^(BOOL result){}];
}

+ (void)pushUrl:(NSString *)url
         result:(ThrioBoolCallback)result {
  [self pushUrl:url params:@{} animated:YES result:result];
}

+ (void)pushUrl:(NSString *)url
       animated:(BOOL)animated {
  [self pushUrl:url params:@{} animated:animated result:^(BOOL result){}];
}

+ (void)pushUrl:(NSString *)url
       animated:(BOOL)animated
         result:(ThrioBoolCallback)result {
  [self pushUrl:url params:@{} animated:animated result:result];
}

+ (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params {
  [self pushUrl:url params:params animated:YES result:^(BOOL result){}];
}

+ (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params
         result:(ThrioBoolCallback)result {
  [self pushUrl:url params:params animated:YES result:result];
}

+ (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params
       animated:(BOOL)animated {
  [self pushUrl:url params:params animated:YES result:^(BOOL result){}];
}

+ (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params
       animated:(BOOL)animated
         result:(ThrioBoolCallback)result {
  if ([self canPushUrl:url params:params]) {
    [self.navigationController thrio_pushUrl:url
                                      params:params
                                    animated:animated
                                      result:^(BOOL r) {
      result(r);
    }];
  }
}
#pragma mark - notify methods

+ (void)notifyUrl:(NSString *)url name:(NSString *)name {
  [self notifyUrl:url index:@0 name:name params:@{} result:^(BOOL result){}];
}

+ (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           result:(ThrioBoolCallback)result {
  [self notifyUrl:url index:@0 name:name params:@{} result:result];
}

+ (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name {
  [self notifyUrl:url index:index name:name params:@{} result:^(BOOL result){}];
}

+ (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           result:(ThrioBoolCallback)result {
  [self notifyUrl:url index:index name:name params:@{} result:result];
}

+ (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           params:(NSDictionary *)params {
  [self notifyUrl:url index:@0 name:name params:params result:^(BOOL result){}];
}

+ (void)notifyUrl:(NSString *)url
             name:(NSString *)name
           params:(NSDictionary *)params
           result:(ThrioBoolCallback)result {
  [self notifyUrl:url index:@0 name:name params:params result:result];
}

+ (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           params:(NSDictionary *)params {
  [self notifyUrl:url index:index name:name params:params result:^(BOOL result){}];
}

+ (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           params:(NSDictionary *)params
           result:(ThrioBoolCallback)result {
  BOOL canNotify = [self canNotifyUrl:url index:index];
  if (canNotify) {
    canNotify = [self.navigationController thrio_notifyUrl:url
                                                     index:index
                                                      name:name
                                                    params:params];
  }
  if (result) {
    result(canNotify);
  }
}

#pragma mark - pop methods

+ (void)pop {
  [self popAnimated:YES result:^(BOOL result){}];
}

+ (void)popAnimated:(BOOL)animated {
  [self popAnimated:animated result:^(BOOL result){}];
}

+ (void)popAnimated:(BOOL)animated result:(ThrioBoolCallback)result {
  if ([self canPop]) {
    [self.navigationController thrio_popAnimated:animated result:^(BOOL r) {
      result(r);
    }];
  }
}

#pragma mark - popTo methods

+ (void)popToUrl:(NSString *)url {
  [self popToUrl:url index:@0 animated:YES result:^(BOOL result){}];
}

+ (void)popToUrl:(NSString *)url
          result:(ThrioBoolCallback)result {
  [self popToUrl:url index:@0 animated:YES result:result];
}

+ (void)popToUrl:(NSString *)url
           index:(NSNumber *)index {
  [self popToUrl:url index:index animated:YES result:^(BOOL result){}];
}

+ (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
          result:(ThrioBoolCallback)result {
  [self popToUrl:url index:index animated:YES result:result];
}

+ (void)popToUrl:(NSString *)url
        animated:(BOOL)animated {
  [self popToUrl:url index:@0 animated:animated result:^(BOOL result){}];
}

+ (void)popToUrl:(NSString *)url
        animated:(BOOL)animated
          result:(ThrioBoolCallback)result {
  [self popToUrl:url index:@0 animated:animated result:result];
}

+ (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
        animated:(BOOL)animated {
  [self popToUrl:url index:@0 animated:animated result:^(BOOL result){}];
}

+ (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
        animated:(BOOL)animated
          result:(ThrioBoolCallback)result {
  if ([self canPopToUrl:url index:index]) {
    [self.navigationController thrio_popToUrl:url
                                        index:index
                                     animated:animated
                                       result:^(BOOL r) {
      result(r);
    }];
  }
}

#pragma mark - remove methods

+ (void)removeUrl:(NSString *)url {
  [self removeUrl:url index:@0 animated:YES result:^(BOOL result){}];
}

+ (void)removeUrl:(NSString *)url
     result:(ThrioBoolCallback)result {
  [self removeUrl:url index:@0 animated:YES result:result];
}

+ (void)removeUrl:(NSString *)url
      index:(NSNumber *)index {
  [self removeUrl:url index:index animated:YES result:^(BOOL result){}];
}

+ (void)removeUrl:(NSString *)url
      index:(NSNumber *)index
     result:(ThrioBoolCallback)result {
  [self removeUrl:url index:index animated:YES result:result];
}

+ (void)removeUrl:(NSString *)url
   animated:(BOOL)animated {
  [self removeUrl:url index:@0 animated:animated result:^(BOOL result){}];
}

+ (void)removeUrl:(NSString *)url
   animated:(BOOL)animated
     result:(ThrioBoolCallback)result {
  [self removeUrl:url index:@0 animated:animated result:result];
}

+ (void)removeUrl:(NSString *)url
      index:(NSNumber *)index
   animated:(BOOL)animated {
  [self removeUrl:url index:@0 animated:animated result:^(BOOL result){}];
}

+ (void)removeUrl:(NSString *)url
            index:(NSNumber *)index
         animated:(BOOL)animated
           result:(ThrioBoolCallback)result {
  if ([self canRemoveUrl:url index:index]) {
    [self.navigationController thrio_removeUrl:url
                                         index:index
                                      animated:animated
                                        result:^(BOOL r) {
      result(r);
    }];
  }
}

#pragma mark - predicate methods

+ (BOOL)canPushUrl:(NSString *)url params:(NSDictionary * _Nullable)params {
  return self.navigationController != nil;
}

+ (BOOL)canNotifyUrl:(NSString *)url index:(NSNumber * _Nullable)index {
  return [self.navigationController thrio_ContainsUrl:url index:index];
}

+ (BOOL)canPop {
  UINavigationController *nvc = self.navigationController;
  return (nvc.viewControllers.count > 1 ||
          nvc.topViewController.thrio_firstRoute != nvc.topViewController.thrio_lastRoute) &&
         !nvc.topViewController.thrio_lastRoute.popDisabled;
}

+ (BOOL)canPopToUrl:(NSString *)url index:(NSNumber * _Nullable)index {
  return [self.navigationController thrio_ContainsUrl:url index:index];
}

+ (BOOL)canRemoveUrl:(NSString *)url index:(NSNumber * _Nullable)index {
  return [self.navigationController thrio_ContainsUrl:url index:index];
}

#pragma mark - get index methods

+ (NSNumber *)lastIndex {
  return [self.navigationController thrio_lastIndex];
}

+ (NSNumber *)getLastIndexByUrl:(NSString *)url {
  return [self.navigationController thrio_getLastIndexByUrl:url];
}

+ (NSArray *)getAllIndexByUrl:(NSString *)url {
  return [self.navigationController thrio_getAllIndexByUrl:url];
}

#pragma mark - set pop disabled methods

+ (void)setPopDisabled:(BOOL)disabled {
  return [self setPopDisabledUrl:@"" index:@0 disabled:disabled];
}

+ (void)setPopDisabledUrl:(NSString *)url disabled:(BOOL)disabled {
  return [self setPopDisabledUrl:url index:@0 disabled:disabled];
}

+ (void)setPopDisabledUrl:(NSString *)url index:(NSNumber *)index disabled:(BOOL)disabled {
  return [self.navigationController thrio_setPopDisabledUrl:url index:index disabled:disabled];
}

#pragma mark - multi-engine methods

static BOOL multiEngineEnabled = YES;

+ (void)setMultiEngineEnabled:(BOOL)enabled {
  multiEngineEnabled = enabled;
}

+ (BOOL)isMultiEngineEnabled {
  return multiEngineEnabled;
}

@end

NS_ASSUME_NONNULL_END
