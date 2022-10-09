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

#import "NavigatorConsts.h"
#import "NavigatorFlutterEngine.h"
#import "NavigatorFlutterEngineFactory.h"
#import "NavigatorFlutterEngineGroup.h"
#import "NavigatorLogger.h"
#import "ThrioChannel.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioNavigator.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorFlutterEngineFactory ()

@property (nonatomic, strong) NSMutableDictionary *engineGroups;

@end

@implementation NavigatorFlutterEngineFactory


+ (instancetype)shared {
    static NavigatorFlutterEngineFactory *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.engineGroups = [NSMutableDictionary dictionary];
    });
    return _instance;
}


- (NavigatorFlutterEngine *)startupWithEntrypoint:(NSString *)entrypoint
                   readyBlock:(ThrioEngineReadyCallback _Nullable)block {
    if (!_multiEngineEnabled) {
        entrypoint = kNavigatorDefaultEntrypoint;
    }
    NavigatorFlutterEngineGroup *engineGroup = _engineGroups[entrypoint];
    if (!engineGroup) {
        engineGroup = [[NavigatorFlutterEngineGroup alloc] initWithEntrypoint:entrypoint];
        _engineGroups[entrypoint] = engineGroup;
    }
    return [engineGroup startupWithReadyBlock:block];
}

- (BOOL)isMainEngineByPageId:(NSUInteger)pageId withEntrypoint:(NSString *)entrypoint {
    return [_engineGroups[@(pageId)] isMainEngineByPageId:pageId];
}

- (NavigatorFlutterEngine *_Nullable)getEngineByPageId:(NSUInteger)pageId withEntrypoint:(NSString *)entrypoint {
    if (!_multiEngineEnabled) {
        entrypoint = kNavigatorDefaultEntrypoint;
    }
    NavigatorFlutterEngineGroup *engineGroup = _engineGroups[entrypoint];
    return [engineGroup getEngineByPageId:pageId];
}

- (void)destroyEngineByPageId:(NSUInteger)pageId withEntrypoint:(NSString *)entrypoint {
    [_engineGroups[entrypoint] destroyEngineByPageId:pageId];
}

- (NavigatorRouteSendChannel *)getSendChannelByPageId:(NSUInteger)pageId withEntrypoint:(NSString *)entrypoint {
    return [self getEngineByPageId:pageId withEntrypoint:entrypoint].sendChannel;
}

- (ThrioChannel *)getModuleChannelByPageId:(NSUInteger)pageId withEntrypoint:(NSString *)entrypoint {
    return [self getEngineByPageId:pageId withEntrypoint:entrypoint].moduleContextChannel;
}

- (void)setModuleContextValue:(id _Nullable)value forKey:(NSString *)key {
    NSArray *engineGroups = [_engineGroups.allValues copy];
    for (NavigatorFlutterEngineGroup *engineGroup in engineGroups) {
        NSArray *engines = engineGroup.engines;
        for (NavigatorFlutterEngine *engine in engines) {
            [engine.moduleContextChannel invokeMethod:@"set" arguments:@{ key: value }];
        }
    }
}

#pragma mark - NavigatorRouteObserverProtocol methods

- (void)didPush:(NavigatorRouteSettings *)routeSettings {
    NSArray *engineGroups = [_engineGroups.allValues copy];
    for (NavigatorFlutterEngineGroup *engineGroup in engineGroups) {
        NSArray *engines = engineGroup.engines;
        for (NavigatorFlutterEngine *engine in engines) {
            [engine.routeChannel didPush:routeSettings];
        }
    }
}

- (void)didPop:(NavigatorRouteSettings *)routeSettings {
    NSArray *engineGroups = [_engineGroups.allValues copy];
    for (NavigatorFlutterEngineGroup *engineGroup in engineGroups) {
        NSArray *engines = engineGroup.engines;
        for (NavigatorFlutterEngine *engine in engines) {
            [engine.routeChannel didPop:routeSettings];
        }
    }
}

- (void)didPopTo:(NavigatorRouteSettings *)routeSettings {
    NSArray *engineGroups = [_engineGroups.allValues copy];
    for (NavigatorFlutterEngineGroup *engineGroup in engineGroups) {
        NSArray *engines = engineGroup.engines;
        for (NavigatorFlutterEngine *engine in engines) {
            [engine.routeChannel didPopTo:routeSettings];
        }
    }
}

- (void)didRemove:(NavigatorRouteSettings *)routeSettings {
    NSArray *engineGroups = [_engineGroups.allValues copy];
    for (NavigatorFlutterEngineGroup *engineGroup in engineGroups) {
        NSArray *engines = engineGroup.engines;
        for (NavigatorFlutterEngine *engine in engines) {
            [engine.routeChannel didRemove:routeSettings];
        }
    }
}

- (void)didReplace:(NavigatorRouteSettings *)newRouteSettings
  oldRouteSettings:(NavigatorRouteSettings *)oldRouteSettings {
    NSArray *engineGroups = [_engineGroups.allValues copy];
    for (NavigatorFlutterEngineGroup *engineGroup in engineGroups) {
        NSArray *engines = engineGroup.engines;
        for (NavigatorFlutterEngine *engine in engines) {
            [engine.routeChannel didReplace:newRouteSettings oldRouteSettings:oldRouteSettings];
        }
    }
}

#pragma mark - NavigatorPageObserverProtocol methods

- (void)willAppear:(NavigatorRouteSettings *)routeSettings {
    NSArray *engineGroups = [_engineGroups.allValues copy];
    for (NavigatorFlutterEngineGroup *engineGroup in engineGroups) {
        NSArray *engines = engineGroup.engines;
        for (NavigatorFlutterEngine *engine in engines) {
            [engine.pageChannel willAppear:routeSettings];
        }
    }
}

- (void)didAppear:(NavigatorRouteSettings *)routeSettings {
    NSArray *engineGroups = [_engineGroups.allValues copy];
    for (NavigatorFlutterEngineGroup *engineGroup in engineGroups) {
        NSArray *engines = engineGroup.engines;
        for (NavigatorFlutterEngine *engine in engines) {
            [engine.pageChannel didAppear:routeSettings];
        }
    }
}

- (void)willDisappear:(NavigatorRouteSettings *)routeSettings {
    NSArray *engineGroups = [_engineGroups.allValues copy];
    for (NavigatorFlutterEngineGroup *engineGroup in engineGroups) {
        NSArray *engines = engineGroup.engines;
        for (NavigatorFlutterEngine *engine in engines) {
            [engine.pageChannel willDisappear:routeSettings];
        }
    }
}

- (void)didDisappear:(NavigatorRouteSettings *)routeSettings {
    NSArray *engineGroups = [_engineGroups.allValues copy];
    for (NavigatorFlutterEngineGroup *engineGroup in engineGroups) {
        NSArray *engines = engineGroup.engines;
        for (NavigatorFlutterEngine *engine in engines) {
            [engine.pageChannel didDisappear:routeSettings];
        }
    }
}

@end

NS_ASSUME_NONNULL_END
