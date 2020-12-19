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

@property (nonatomic, copy, readwrite) NSString *url;

@property (nonatomic, strong, readwrite, nullable) NSNumber *index;

@property (nonatomic, assign, readwrite) BOOL nested;

@property (nonatomic, copy, readwrite, nullable) id params;

@end

@implementation NavigatorRouteSettings

+ (instancetype)settingsWithUrl:(NSString *)url
                          index:(NSNumber *_Nullable)index
                         nested:(BOOL)nested
                         params:(id _Nullable)params {
    return [[self alloc] initWithUrl:url index:index nested:nested params:params];
}

- (instancetype)initWithUrl:(NSString *)url
                      index:(NSNumber *_Nullable)index
                     nested:(BOOL)nested
                     params:(id _Nullable)params {
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

+ (id _Nullable)settingsFromArguments:(NSDictionary *)arguments {
    NSString *url = arguments[@"url"];
    NSNumber *index = [arguments[@"index"] isKindOfClass:NSNull.class] ? nil : arguments[@"index"];
    id params = [arguments[@"params"] isKindOfClass:NSNull.class] ? nil : arguments[@"params"];
    BOOL animated = [arguments[@"animated"] boolValue];
    return [self settingsWithUrl:url index:index nested:animated params:params];
}

- (NSDictionary *)toArguments {
    return [self toArgumentsWithParams:_params];
}

- (NSDictionary *)toArgumentsWithParams:(id _Nullable)params {
    return params ? @{
        @"url": _url,
        @"index": _index,
        @"isNested": @(_nested),
        @"params": params,
    } : @{
        @"url": _url,
        @"index": _index,
        @"isNested": @(_nested),
    };
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
