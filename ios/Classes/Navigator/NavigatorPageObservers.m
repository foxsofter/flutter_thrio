// The MIT License (MIT)
//
// Copyright (c) 2019 foxsofter
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

#import "NavigatorFlutterEngineFactory.h"
#import "NavigatorLogger.h"
#import "NavigatorPageObserverChannel.h"
#import "NavigatorPageObservers.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorPageObservers ()

@property (nonatomic, readwrite) ThrioRegistrySet<id<NavigatorPageObserverProtocol> > *observers;

@property (nonatomic, readwrite) NavigatorPageRoute *prevLastRoute;

@end

@implementation NavigatorPageObservers

- (instancetype)init {
    if (self = [super init]) {
        _observers = [ThrioRegistrySet set];
        [_observers registry:NavigatorFlutterEngineFactory.shared];
    }
    return self;
}

- (void)setLastRoute:(NavigatorPageRoute *)lastRoute {
    if (_lastRoute != lastRoute) {
        if (_lastRoute) {
            _prevLastRoute = _lastRoute;
        }
        _lastRoute = lastRoute;
    }
}

#pragma mark - NavigatorPageObserverProtocol methods

- (void)willAppear:(NavigatorRouteSettings *)routeSettings {
    if (!routeSettings) {
        return;
    }
    NavigatorVerbose(@"%@: url->%@ index->%@",
                     NSStringFromSelector(_cmd),
                     routeSettings.url,
                     routeSettings.index);
    ThrioRegistrySet *pageObservers = [self.observers copy];
    for (id<NavigatorPageObserverProtocol> observer in pageObservers) {
        if ([observer respondsToSelector:@selector(willAppear:)]) {
            [observer willAppear:routeSettings];
        }
    }
}

- (void)didAppear:(NavigatorRouteSettings *)routeSettings {
    if (!routeSettings) {
        return;
    }
    NavigatorVerbose(@"%@: url->%@ index->%@",
                     NSStringFromSelector(_cmd),
                     routeSettings.url,
                     routeSettings.index);
    ThrioRegistrySet *pageObservers = [self.observers copy];
    for (id<NavigatorPageObserverProtocol> observer in pageObservers) {
        if ([observer respondsToSelector:@selector(didAppear:)]) {
            [observer didAppear:routeSettings];
        }
    }
}

- (void)willDisappear:(NavigatorRouteSettings *)routeSettings {
    if (!routeSettings) {
        return;
    }
    NavigatorVerbose(@"%@: url->%@ index->%@",
                     NSStringFromSelector(_cmd),
                     routeSettings.url,
                     routeSettings.index);
    ThrioRegistrySet *pageObservers = [self.observers copy];
    for (id<NavigatorPageObserverProtocol> observer in pageObservers) {
        if ([observer respondsToSelector:@selector(willDisappear:)]) {
            [observer willDisappear:routeSettings];
        }
    }
}

- (void)didDisappear:(NavigatorRouteSettings *)routeSettings {
    if (!routeSettings) {
        return;
    }
    NavigatorVerbose(@"%@: url->%@ index->%@",
                     NSStringFromSelector(_cmd),
                     routeSettings.url,
                     routeSettings.index);
    ThrioRegistrySet *pageObservers = [self.observers copy];
    for (id<NavigatorPageObserverProtocol> observer in pageObservers) {
        if ([observer respondsToSelector:@selector(didDisappear:)]) {
            [observer didDisappear:routeSettings];
        }
    }
}

@end

NS_ASSUME_NONNULL_END
