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

#import "NavigatorFlutterEngine.h"
#import "NavigatorFlutterEngineFactory.h"
#import "NavigatorLogger.h"
#import "ThrioChannel.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioNavigator.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorFlutterEngineFactory ()

@property (nonatomic, strong) NSMutableDictionary *flutterEngines;

@end

@implementation NavigatorFlutterEngineFactory

static NSString *const kDefaultEntrypoint = @"main";

+ (instancetype)shared {
    static NavigatorFlutterEngineFactory *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (NSMutableDictionary *)flutterEngines {
    if (!_flutterEngines) {
        _flutterEngines = [NSMutableDictionary dictionary];
    }
    return _flutterEngines;
}

- (void)startupWithEntrypoint:(NSString *)entrypoint
                   readyBlock:(ThrioIdCallback _Nullable)block {
    if (!NavigatorFlutterEngineFactory.shared.multiEngineEnabled) {
        entrypoint = kDefaultEntrypoint;
    }

    if ([self.flutterEngines.allKeys containsObject:entrypoint]) {
        block(entrypoint);
    } else {
        NavigatorVerbose(@"push in startupWithEntrypoint:%@", entrypoint);
        NavigatorFlutterEngine *flutterEngine = [[NavigatorFlutterEngine alloc] init];
        [self.flutterEngines setObject:flutterEngine forKey:entrypoint];
        [flutterEngine startupWithEntrypoint:entrypoint readyBlock:block];
    }
}

- (FlutterEngine *)getEngineByEntrypoint:(NSString *)entrypoint {
    if (!NavigatorFlutterEngineFactory.shared.multiEngineEnabled) {
        entrypoint = kDefaultEntrypoint;
    }
    NavigatorFlutterEngine *flutterEngine = self.flutterEngines[entrypoint];
    return flutterEngine.engine;
}

- (NavigatorRouteSendChannel *)getSendChannelByEntrypoint:(NSString *)entrypoint {
    if (!self.multiEngineEnabled) {
        entrypoint = kDefaultEntrypoint;
    }
    NavigatorFlutterEngine *flutterEngine = self.flutterEngines[entrypoint];
    return flutterEngine.sendChannel;
}

- (ThrioChannel *)getModuleChannelByEntrypoint:(NSString *)entrypoint {
    if (!self.multiEngineEnabled) {
        entrypoint = kDefaultEntrypoint;
    }
    NavigatorFlutterEngine *flutterEngine = self.flutterEngines[entrypoint];
    return flutterEngine.moduleContextChannel;
}

- (void)setModuleContextValue:(id _Nullable)value forKey:(NSString *)key {
    NSArray *flutterEngines = [_flutterEngines.allValues copy];
    for (NavigatorFlutterEngine *flutterEngine in flutterEngines) {
        [flutterEngine.moduleContextChannel invokeMethod:@"set" arguments:@{ key: value }];
    }
}

- (void)pushViewController:(NavigatorFlutterViewController *)viewController {
    NavigatorFlutterEngine *flutterEngine = self.flutterEngines[viewController.entrypoint];
    [flutterEngine pushViewController:viewController];
}

- (void)popViewController:(NavigatorFlutterViewController *)viewController {
    NavigatorFlutterEngine *flutterEngine = self.flutterEngines[viewController.entrypoint];
    [flutterEngine popViewController:viewController];
}

#pragma mark - NavigatorRouteObserverProtocol methods

- (void)didPush:(NavigatorRouteSettings *)routeSettings {
    NSArray *flutterEngines = [_flutterEngines.allValues copy];
    for (NavigatorFlutterEngine *flutterEngine in flutterEngines) {
        [flutterEngine.routeChannel didPush:routeSettings];
    }
}

- (void)didPop:(NavigatorRouteSettings *)routeSettings {
    NSArray *flutterEngines = [_flutterEngines.allValues copy];
    for (NavigatorFlutterEngine *flutterEngine in flutterEngines) {
        [flutterEngine.routeChannel didPop:routeSettings];
    }
}

- (void)didPopTo:(NavigatorRouteSettings *)routeSettings {
    NSArray *flutterEngines = [_flutterEngines.allValues copy];
    for (NavigatorFlutterEngine *flutterEngine in flutterEngines) {
        [flutterEngine.routeChannel didPopTo:routeSettings];
    }
}

- (void)didRemove:(NavigatorRouteSettings *)routeSettings {
    NSArray *flutterEngines = [_flutterEngines.allValues copy];
    for (NavigatorFlutterEngine *flutterEngine in flutterEngines) {
        [flutterEngine.routeChannel didRemove:routeSettings];
    }
}

#pragma mark - NavigatorPageObserverProtocol methods

- (void)willAppear:(NavigatorRouteSettings *)routeSettings {
    NSArray *flutterEngines = [_flutterEngines.allValues copy];
    for (NavigatorFlutterEngine *flutterEngine in flutterEngines) {
        [flutterEngine.pageChannel willAppear:routeSettings];
    }
}

- (void)didAppear:(NavigatorRouteSettings *)routeSettings {
    NSArray *flutterEngines = [_flutterEngines.allValues copy];
    for (NavigatorFlutterEngine *flutterEngine in flutterEngines) {
        [flutterEngine.pageChannel didAppear:routeSettings];
    }
}

- (void)willDisappear:(NavigatorRouteSettings *)routeSettings {
    NSArray *flutterEngines = [_flutterEngines.allValues copy];
    for (NavigatorFlutterEngine *flutterEngine in flutterEngines) {
        [flutterEngine.pageChannel willDisappear:routeSettings];
    }
}

- (void)didDisappear:(NavigatorRouteSettings *)routeSettings {
    NSArray *flutterEngines = [_flutterEngines.allValues copy];
    for (NavigatorFlutterEngine *flutterEngine in flutterEngines) {
        [flutterEngine.pageChannel didDisappear:routeSettings];
    }
}

@end

NS_ASSUME_NONNULL_END
