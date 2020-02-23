//
//  NavigatorPageRoute.m
//  thrio
//
//  Created by foxsofter on 2020/1/19.
//

#import "NavigatorPageRoute.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorPageRoute ()

@property (nonatomic, strong, readwrite) NavigatorRouteSettings *settings;

@end

@implementation NavigatorPageRoute {
  NSMutableDictionary *_notifications;
}

+ (instancetype)routeWithSettings:(NavigatorRouteSettings *)settings {
  return [[self alloc] initWithSettings:settings];
}

- (instancetype)initWithSettings:(NavigatorRouteSettings *)settings {
  self = [super init];
  if (self) {
    _popDisabled = NO;
    _settings = settings;
    _notifications = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)addNotify:(NSString *)name params:(NSDictionary *)params {
  [_notifications setObject:params forKey:name];
}

- (NSDictionary * _Nullable)removeNotify:(NSString *)name {
  NSDictionary *params = _notifications[name];
  [_notifications removeObjectForKey:name];
  return params;
}

- (NSDictionary *)notifications {
  return [_notifications copy];
}

@end

NS_ASSUME_NONNULL_END
