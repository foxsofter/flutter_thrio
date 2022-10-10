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

#import "NavigatorPageRoute.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorPageRoute ()

@property (nonatomic, readwrite) NavigatorRouteSettings *settings;

@end

@implementation NavigatorPageRoute
{
    NSMutableDictionary *_notifications;
}

+ (instancetype)routeWithSettings:(NavigatorRouteSettings *)settings {
    return [[self alloc] initWithSettings:settings];
}

- (instancetype)initWithSettings:(NavigatorRouteSettings *)settings {
    self = [super init];
    if (self) {
        _settings = settings;
        _notifications = [NSMutableDictionary dictionary];
        }
    return self;
}

- (void)addNotify:(NSString *)name params:(id _Nullable)params {
    if (!params) {
        [_notifications setObject:[NSNull null] forKey:name];
    } else {
        [_notifications setObject:params forKey:name];
    }
}

- (NSDictionary *)removeNotify {
    NSDictionary *notifies = [_notifications copy];
    [_notifications removeAllObjects];
    return notifies;
}

- (NSDictionary *)notifications {
    return [_notifications copy];
}

@end

NS_ASSUME_NONNULL_END
