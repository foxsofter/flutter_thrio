// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

#import "NavigatorRouteSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorRouteSettings ()

@end

@implementation NavigatorRouteSettings

+ (instancetype)settingsWithUrl:(NSString *)url
                          index:(NSNumber *_Nullable)index
                         params:(id _Nullable)params
                       animated:(BOOL)animated
                         nested:(BOOL)nested
                        fromURL:(NSString *_Nullable)fromURL
                        prevURL:(NSString *_Nullable)prevURL
                       innerURL:(NSString *_Nullable)innerURL {
    return [[self alloc] initWithUrl:url
                               index:index
                              params:params
                            animated:animated
                              nested:nested
                             fromURL:fromURL
                             prevURL:prevURL
                            innerURL:innerURL];
}

- (instancetype)initWithUrl:(NSString *)url
                      index:(NSNumber *_Nullable)index
                     params:(id _Nullable)params
                   animated:(BOOL)animated
                     nested:(BOOL)nested
                    fromURL:(NSString *_Nullable)fromURL
                    prevURL:(NSString *_Nullable)prevURL
                   innerURL:(NSString *_Nullable)innerURL
{
    NSAssert(url && url.length > 0, @"url must not be null or empty.");
    
    self = [super init];
    if (self) {
        _url = url;
        _index = index;
        _params = params;
        _animated = animated;
        _nested = nested;
        _fromURL = fromURL;
        _prevURL = prevURL;
        _innerURL = innerURL;
    }
    return self;
}

+ (id _Nullable)settingsFromArguments:(NSDictionary *)arguments {
    NSString *url = arguments[@"url"];
    NSNumber *index = [arguments[@"index"] isKindOfClass:NSNull.class] ? nil : arguments[@"index"];
    id params = [arguments[@"params"] isKindOfClass:NSNull.class] ? nil : arguments[@"params"];
    BOOL animated = [arguments[@"animated"] boolValue];
    BOOL nested = [arguments[@"isNested"] boolValue];
    NSString *fromURL = arguments[@"fromURL"];
    NSString *prevURL = arguments[@"prevURL"];
    NSString *innerURL = arguments[@"innerURL"];
    NavigatorRouteSettings *settings = [self settingsWithUrl:url
                                                       index:index
                                                      params:params
                                                    animated:animated
                                                      nested:nested
                                                     fromURL:fromURL
                                                     prevURL:prevURL
                                                    innerURL:innerURL];
    return  settings;
}

- (NSDictionary *)toArguments {
    return [self toArgumentsWithParams:_params];
}

- (NSDictionary *)toArgumentsWithParams:(id _Nullable)params {
    NSMutableDictionary * args = @{
        @"url": _url,
        @"index": _index,
        @"animated": @(_animated),
        @"isNested": @(_nested)
    }.mutableCopy;
    if (params) {
        args[@"params"] = params;
    }
    if (_fromURL) {
        args[@"fromURL"] = _fromURL;
    }
    if (_prevURL) {
        args[@"prevURL"] = _prevURL;
    }
    if (_innerURL) {
        args[@"innerURL"] = _innerURL;
    }
    return args.copy;
}

- (NSDictionary *)toArgumentsWithNewUrl:(NSString *)newUrl newIndex:(NSNumber *)newIndex {
    NSMutableDictionary * args = @{
        @"url": _url,
        @"index": _index,
        @"isNested": @(_nested),
        @"newUrl": newUrl,
        @"newIndex": newIndex,
    }.mutableCopy;
    if (_fromURL) {
        args[@"fromURL"] = _fromURL;
    }
    if (_prevURL) {
        args[@"prevURL"] = _prevURL;
    }
    if (_innerURL) {
        args[@"innerURL"] = _innerURL;
    }
    return args.copy;
}

- (NSString *)name {
    return [NSString stringWithFormat:@"%@ %@", _index == nil ? @0 : _index, _url];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"settings: %@", [self toArguments]];
}

- (BOOL)isEqualToRouteSettings:(NavigatorRouteSettings *)other {
    return [self.url isEqualToString:other.url] && [self.index isEqualToNumber:other.index];
}

@end

NS_ASSUME_NONNULL_END
