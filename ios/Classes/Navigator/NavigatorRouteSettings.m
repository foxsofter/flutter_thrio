//
//  NavigatorRouteSettings.m
//  Pods-Runner
//
//  Created by foxsofter on 2020/1/19.
//

#import "NavigatorRouteSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorRouteSettings ()

@property (nonatomic, copy, readwrite) NSString *url;

@property (nonatomic, strong, readwrite) NSNumber *index;

@property (nonatomic, assign, readwrite) BOOL nested;

@property (nonatomic, copy, readwrite) NSDictionary *params;

@end

@implementation NavigatorRouteSettings

+ (instancetype)settingsWithUrl:(NSString *)url
                          index:(NSNumber *)index
                         nested:(BOOL)nested
                         params:(NSDictionary *)params {
  return [[self alloc] initWithUrl:url index:index nested:nested params:params];
}

- (instancetype)initWithUrl:(NSString *)url
                      index:(NSNumber *)index
                     nested:(BOOL)nested
                     params:(NSDictionary *)params {
  NSAssert(url && url.length > 0, @"url must not be null or empty.");

  self = [super init];
  if (self) {
    _url = url;
    _index = index;
    _nested = nested;
    _params = params;
  }
  return self;
}

- (NSDictionary *)toArguments {
  return @{
    @"url": _url,
    @"index": _index,
    @"isNested": @(_nested),
    @"params": _params,
  };
}

- (NSDictionary *)toArgumentsWithoutParams {
  return @{
    @"url": _url,
    @"index": _index,
    @"isNested": @(_nested),
  };
}

- (NSString *)description {
  return [NSString stringWithFormat:@"settings: %@", [self toArguments]];
}

@end

NS_ASSUME_NONNULL_END
