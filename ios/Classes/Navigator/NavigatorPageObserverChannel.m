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
#import "ThrioModule+PageObservers.h"
#import "ThrioNavigator.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorPageObserverChannel ()

@property (nonatomic, strong) ThrioChannel *channel;

@end

@implementation NavigatorPageObserverChannel

- (instancetype)initWithChannel:(ThrioChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
        [self on:@"willAppear"];
        [self on:@"didAppear"];
        [self on:@"willDisappear"];
        [self on:@"didDisappear"];
    }
    return self;
}

#pragma mark - NavigatorFlutterEngineIdentifier methods

- (NSString *)entrypoint {
    return _channel.entrypoint;
}

- (NSUInteger)pageId {
    return _channel.pageId;
}


#pragma mark - NavigatorPageObserverProtocol methods

/// Send `willAppear` to all flutter engines.
///
- (void)willAppear:(NavigatorRouteSettings *)routeSettings {
    NSDictionary *arguments = [routeSettings toArgumentsWithParams:nil];
    [_channel invokeMethod:@"willAppear" arguments:arguments];
}

/// Send `didAppear` to all flutter engines.
///
- (void)didAppear:(NavigatorRouteSettings *)routeSettings {
    NSDictionary *arguments = [routeSettings toArgumentsWithParams:nil];
    [_channel invokeMethod:@"didAppear" arguments:arguments];
}

/// Send `willDisappear` to all flutter engines.
///
- (void)willDisappear:(NavigatorRouteSettings *)routeSettings {
    NSDictionary *arguments = [routeSettings toArgumentsWithParams:nil];
    [_channel invokeMethod:@"willDisappear" arguments:arguments];
}

/// Send `didDisappear` to all flutter engines.
///
- (void)didDisappear:(NavigatorRouteSettings *)routeSettings {
    NSDictionary *arguments = [routeSettings toArgumentsWithParams:nil];
    [_channel invokeMethod:@"didDisappear" arguments:arguments];
}

#pragma mark - private methods

- (void)on:(NSString *)method {
    [_channel registryMethod:method handler:
     ^void (NSDictionary<NSString *, id> *arguments,
            ThrioIdCallback _Nullable result) {
        NavigatorRouteSettings *settings = [NavigatorRouteSettings settingsFromArguments:arguments];
        NSString *routeTypeString = arguments[@"routeType"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:routeType:", method]);
        [ThrioModule performSelector:selector withObject:settings withObject:routeTypeString];
#pragma clang diagnostic pop
    }];
}

@end

NS_ASSUME_NONNULL_END
