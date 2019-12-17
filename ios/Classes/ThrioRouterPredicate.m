//
//  ThrioRouterPredicate.m
//  thrio_router
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioRouterPredicate.h"

@interface ThrioRouterPredicate ()

@property (nonatomic, copy) ThrioNotifyPredicate _canNotify;

@property (nonatomic, copy) ThrioPopPredicate _canPop;

@property (nonatomic, copy) ThrioPopToPredicate _canPopTo;

@property (nonatomic, copy) ThrioPushPredicate _canPush;

@end

@implementation ThrioRouterPredicate

+ (instancetype)predicate {
  return [[self alloc] init];
}

- (instancetype)setCanNotify:(ThrioNotifyPredicate)canNotify {
  __canNotify = canNotify;
  return self;
}

- (instancetype)setCanPop:(ThrioPopPredicate)canPop {
  __canPop = canPop;
  return self;
}

- (instancetype)setCanPopTo:(ThrioPopToPredicate)canPopTo {
  __canPopTo = canPopTo;
  return self;
}

- (instancetype)setCanPush:(ThrioPushPredicate)canPush {
  __canPush = canPush;
  return self;
}

- (BOOL)canNotify:(NSString *)url
            index:(nullable NSNumber *)index
           params:(nullable NSDictionary *)params {
  if (__canNotify) {
    return __canNotify(url, index, params);
  }
  return YES;
}

- (BOOL)canPop:(NSString *)url index:(nullable NSNumber *)index {
  if (__canPop) {
    return __canPop(url, index);
  }
  return YES;
}

- (BOOL)canPopTo:(NSString *)url index:(nullable NSNumber *)index {
  if (__canPopTo) {
    return __canPopTo(url, index);
  }
  return YES;
}

- (BOOL)canPush:(NSString *)url
         params:(nullable NSDictionary *)params {
  if (__canPush) {
    return __canPush(url, params);
  }
  return YES;
}

@end
