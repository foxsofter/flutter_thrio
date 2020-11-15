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

#import "NavigatorFlutterEngineFactory.h"
#import "NavigatorLogger.h"
#import "NavigatorRouteReceiveChannel.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioNavigator+PageBuilders.h"
#import "UINavigationController+HotRestart.h"
#import "UINavigationController+Navigator.h"
#import "UINavigationController+PopDisabled.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorRouteReceiveChannel ()

@property (nonatomic, strong) ThrioChannel *channel;

@property (nonatomic, copy, nullable) ThrioIdCallback readyBlock;

@end

@implementation NavigatorRouteReceiveChannel

- (instancetype)initWithChannel:(ThrioChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
        [self _onReady];
        [self _onPush];
        [self _onNotify];
        [self _onPop];
        [self _onPopTo];
        [self _onRemove];
        [self _onLastIndex];
        [self _onGetAllIndexs];
        [self _onSetPopDisabled];
        [self _onHotRestart];
        [self _onRegisterUrls];
        [self _onUnregisterUrls];
    }
    return self;
}

- (void)setReadyBlock:(ThrioIdCallback _Nullable)block {
    _readyBlock = block;
}

#pragma mark - on channel methods

- (void)_onReady {
    __weak typeof(self) weakself = self;
    [_channel registryMethod:@"ready"
                     handler:
     ^void (NSDictionary<NSString *, id> *arguments,
            ThrioIdCallback _Nullable result) {
                __strong typeof(weakself) strongSelf = weakself;
                if (strongSelf.readyBlock) {
                    NavigatorVerbose(@"on ready: %@",
                                     strongSelf.channel.entrypoint);
                    strongSelf.readyBlock(strongSelf.channel.entrypoint);
                    strongSelf.readyBlock = nil;
                }
            }];
}

- (void)_onPush {
    __weak typeof(self) weakself = self;
    [_channel registryMethod:@"push"
                     handler:
     ^void (NSDictionary<NSString *, id> *arguments,
            ThrioIdCallback _Nullable result) {
                NSString *url = arguments[@"url"];
                if (url.length < 1) {
                    if (result) {
                        result(nil);
                    }
                    return;
                }
                id params =
                    [arguments[@"params"] isKindOfClass:NSNull.class]
            ? nil
            : arguments[@"params"];
                BOOL animated = [arguments[@"animated"] boolValue];
                NavigatorVerbose(@"on push: %@", url);
                __strong typeof(weakself) strongSelf = weakself;
                [ThrioNavigator _pushUrl:url
                                  params:params
                                animated:animated
                          fromEntrypoint:strongSelf.channel.entrypoint
                                  result:^(NSNumber *idx) {
                                      result(idx);
                                  }
                            poppedResult:nil];
            }];
}

- (void)_onNotify {
    [_channel registryMethod:@"notify"
                     handler:
     ^void (NSDictionary<NSString *, id> *arguments,
            ThrioIdCallback _Nullable result) {
                NSString *name = arguments[@"name"];
                if (name.length < 1) {
                    if (result) {
                        result(@NO);
                    }
                    return;
                }
                NSString *url = arguments[@"url"];
                if (url.length < 1) {
                    if (result) {
                        result(@NO);
                    }
                    return;
                }
                NSNumber *index =
                    [arguments[@"index"] isKindOfClass:NSNull.class]
            ? nil
            : arguments[@"index"];
                id params =
                    [arguments[@"params"] isKindOfClass:NSNull.class]
            ? nil
            : arguments[@"params"];
                [ThrioNavigator _notifyUrl:url
                                     index:index
                                      name:name
                                    params:params
                                    result:^(BOOL r) {
                                        if (result) {
                                            result(@(r));
                                        }
                                    }];
            }];
}

- (void)_onPop {
    [_channel registryMethod:@"pop"
                     handler:
     ^void (NSDictionary<NSString *, id> *arguments,
            ThrioIdCallback _Nullable result) {
                id params =
                    [arguments[@"params"] isKindOfClass:NSNull.class]
            ? nil
            : arguments[@"params"];
                BOOL animated = [arguments[@"animated"] boolValue];

                NavigatorVerbose(@"on pop");
                [ThrioNavigator _popParams:params
                                  animated:animated
                                    result:^(BOOL r) {
                                        if (result) {
                                            result(@(r));
                                        }
                                    }];
            }];
}

- (void)_onPopTo {
    [_channel registryMethod:@"popTo"
                     handler:
     ^void (NSDictionary<NSString *, id> *arguments,
            ThrioIdCallback _Nullable result) {
                NSString *url = arguments[@"url"];
                if (url.length < 1) {
                    if (result) {
                        result(@NO);
                    }
                    return;
                }
                NSNumber *index =
                    [arguments[@"index"] isKindOfClass:NSNull.class]
            ? nil
            : arguments[@"index"];
                BOOL animated = [arguments[@"animated"] boolValue];

                NavigatorVerbose(@"on popTo: %@.%@", url, index);

                [ThrioNavigator _popToUrl:url
                                    index:index
                                 animated:animated
                                   result:^(BOOL r) {
                                       if (result) {
                                           result(@(r));
                                       }
                                   }];
            }];
}

- (void)_onRemove {
    [_channel registryMethod:@"remove"
                     handler:
     ^void (NSDictionary<NSString *, id> *arguments,
            ThrioIdCallback _Nullable result) {
                NSString *url = arguments[@"url"];
                NSNumber *index =
                    [arguments[@"index"] isKindOfClass:NSNull.class]
            ? nil
            : arguments[@"index"];
                BOOL animated = [arguments[@"animated"] boolValue];

                NavigatorVerbose(@"on remove: %@.%@", url, index);

                [ThrioNavigator _removeUrl:url
                                     index:index
                                  animated:animated
                                    result:^(BOOL r) {
                                        if (result) {
                                            result(@(r));
                                        }
                                    }];
            }];
}

- (void)_onLastIndex {
    [_channel registryMethod:@"lastRoute"
                     handler:
     ^void (NSDictionary<NSString *, id> *arguments,
            ThrioIdCallback _Nullable result) {
                if (result) {
                    NSString *url = arguments[@"url"];
                    NavigatorPageRoute *lastRoute = nil;
                    if (url.length < 1) {
                        lastRoute = [ThrioNavigator lastRoute];
                    } else {
                        lastRoute = [ThrioNavigator getLastRouteByUrl:url];
                    }
                    result(lastRoute.settings.index);
                }
            }];
}

- (void)_onGetAllIndexs {
    [_channel registryMethod:@"allIndexs"
                     handler:
     ^void (NSDictionary<NSString *, id> *arguments,
            ThrioIdCallback _Nullable result) {
                NSString *url = arguments[@"url"];
                NSArray *allRoutes =
                    [ThrioNavigator getAllRoutesByUrl:url];
                NSMutableArray *allIndexs = [NSMutableArray array];
                for (NavigatorPageRoute *route in allRoutes) {
                    [allIndexs addObject:route.settings.index];
                }
                if (result) {
                    result(allIndexs);
                }
            }];
}

- (void)_onSetPopDisabled {
    [_channel registryMethod:@"setPopDisabled"
                     handler:
     ^void (NSDictionary<NSString *, id> *arguments,
            ThrioIdCallback _Nullable result) {
                NSString *url = arguments[@"url"];
                NSNumber *index = arguments[@"index"];
                BOOL disabled = [arguments[@"disabled"] boolValue];
                NavigatorVerbose(@"setPopDisabled: %@.%@ %@", url, index,
                                 @(disabled));
                [ThrioNavigator _setPopDisabledUrl:url
                                             index:index
                                          disabled:disabled];
            }];
}

- (void)_onHotRestart {
    [_channel registryMethod:@"hotRestart"
                     handler:
     ^void (NSDictionary<NSString *, id> *arguments,
            ThrioIdCallback _Nullable result) {
                if (!NavigatorFlutterEngineFactory.shared.multiEngineEnabled) {
                    [ThrioNavigator _hotRestart:^(BOOL r) {
                        result(@(r));
                    }];
                }
            }];
}

- (void)_onRegisterUrls {
    [_channel
     registryMethod:@"registerUrls"
            handler:
     ^void (NSDictionary<NSString *, id> *arguments,
            ThrioIdCallback _Nullable result) {
                NSArray *urls = arguments[@"urls"];
                [NavigatorFlutterEngineFactory.shared registerFlutterUrls:urls];
            }];
}

- (void)_onUnregisterUrls {
    [_channel registryMethod:@"unregisterUrls"
                     handler:
     ^void (NSDictionary<NSString *, id> *arguments,
            ThrioIdCallback _Nullable result) {
                NSArray *urls = arguments[@"urls"];
                [NavigatorFlutterEngineFactory.shared
                 unregisterFlutterUrls:urls];
            }];
}

@end

NS_ASSUME_NONNULL_END
