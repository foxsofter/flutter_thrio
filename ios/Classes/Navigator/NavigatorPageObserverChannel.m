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

#import "NavigatorPageObserverChannel.h"
#import "ThrioChannel.h"
#import "ThrioNavigator+PageObservers.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorPageObserverChannel ()

@property (nonatomic, strong) ThrioChannel *channel;

@end

@implementation NavigatorPageObserverChannel

- (instancetype)initWithChannel:(ThrioChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
        [self _on:@"onCreate"];
        [self _on:@"willAppear"];
        [self _on:@"didAppear"];
        [self _on:@"willDisappear"];
        [self _on:@"didDisappear"];
    }
    return self;
}

- (void)_on:(NSString *)method {
    [_channel registryMethod:method
                         handler:^void (NSDictionary<NSString *, id> *arguments,
                                        ThrioIdCallback _Nullable result) {
        NavigatorRouteSettings *settings = [NavigatorRouteSettings settingsFromArguments:arguments];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:", method]);
        [ThrioNavigator performSelector:selector withObject:settings];
    #pragma clang diagnostic pop
    }];
}

- (void)onCreate:(NavigatorRouteSettings *)routeSettings {
    NSDictionary *arguments = [routeSettings toArguments];
    [_channel invokeMethod:@"__onOnCreate__" arguments:arguments];
}

- (void)willAppear:(NavigatorRouteSettings *)routeSettings {
    NSDictionary *arguments = [routeSettings toArguments];
    [_channel invokeMethod:@"__onWillAppear__" arguments:arguments];
}

- (void)didAppear:(NavigatorRouteSettings *)routeSettings {
    NSDictionary *arguments = [routeSettings toArguments];
    [_channel invokeMethod:@"__onDidAppear__" arguments:arguments];
}

- (void)willDisappear:(NavigatorRouteSettings *)routeSettings {
    NSDictionary *arguments = [routeSettings toArguments];
    [_channel invokeMethod:@"__onWillDisappear__" arguments:arguments];
}

- (void)didDisappear:(NavigatorRouteSettings *)routeSettings {
    NSDictionary *arguments = [routeSettings toArguments];
    [_channel invokeMethod:@"__onDidDisappear__" arguments:arguments];
}

@end

NS_ASSUME_NONNULL_END
