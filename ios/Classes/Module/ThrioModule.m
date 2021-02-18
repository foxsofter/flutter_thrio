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
#import "NavigatorPageObserverProtocol.h"
#import "NavigatorRouteObserverProtocol.h"
#import "ThrioModule.h"
#import "ThrioModuleContext+Internal.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioModule+PageBuilders.h"
#import "ThrioModule+PageObservers.h"
#import "ThrioModule+RouteObservers.h"
#import "ThrioModule+JsonSerializers.h"
#import "ThrioModuleJsonDeserializer.h"
#import "ThrioModuleJsonSerializer.h"
#import "ThrioModulePageBuilder.h"
#import "ThrioModulePageObserver.h"
#import "ThrioModuleRouteObserver.h"
#import "NSObject+Thrio.h"

@interface ThrioModule ()

@property (nonatomic, readwrite) ThrioModuleContext *moduleContext;

@end

@implementation ThrioModule

static NSMutableDictionary *modules;

+ (void)init:(ThrioModule *)rootModule {
    ThrioModuleContext *moduleContext = [[ThrioModuleContext alloc] init];
    [rootModule registerModule:rootModule withModuleContext:moduleContext];
    [rootModule initModule];
}

+ (void)init:(ThrioModule *)rootModule multiEngineEnabled:(BOOL)enabled {
    NavigatorFlutterEngineFactory.shared.multiEngineEnabled = enabled;
    [ThrioModule init:rootModule];
}

- (void)registerModule:(ThrioModule *)module
     withModuleContext:(ThrioModuleContext *)moduleContext {
    if (!modules) {
        modules = [NSMutableDictionary dictionary];
    }
    NSString *key = NSStringFromClass([module class]);
    if ([[modules allKeys] containsObject:key]) {
        [NSException raise:@"Duplicate registration exception"
                    format:@"%@ already registered", key];
    }
    [modules setObject:module forKey:key];
    module.moduleContext = moduleContext;
    [module onModuleRegister:moduleContext];
}

- (void)initModule {
    NSArray *values = modules.allValues;
    for (ThrioModule *module in values) {
        if ([module respondsToSelector:@selector(onModuleInit:)]) {
            [module onModuleInit:module.moduleContext];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        for (ThrioModule *module in values) {
            if ([module respondsToSelector:@selector(onModuleAsyncInit:)]) {
                [module onModuleAsyncInit:module.moduleContext];
            }
        }
    });
    for (ThrioModule *module in values) {
        if ([module respondsToSelector:@selector(onPageBuilderRegister:)]) {
            [module onPageBuilderRegister:module.moduleContext];
        }
    }
    for (ThrioModule *module in values) {
        if ([module respondsToSelector:@selector(onPageObserverRegister:)]) {
            [module onPageObserverRegister:module.moduleContext];
        }
        if ([module respondsToSelector:@selector(onRouteObserverRegister:)]) {
            [module onRouteObserverRegister:module.moduleContext];
        }
    }
    for (ThrioModule *module in values) {
        if ([module respondsToSelector:@selector(onJsonSerializerRegister:)]) {
            [module onJsonSerializerRegister:module.moduleContext];
        }
        if ([module respondsToSelector:@selector(onJsonDeserializerRegister:)]) {
            [module onJsonDeserializerRegister:module.moduleContext];
        }
    }

    // 单引擎模式下，提前启动，默认 `entrypoint` 为 main
    if (!NavigatorFlutterEngineFactory.shared.multiEngineEnabled) {
        [self startupFlutterEngineWithEntrypoint:@"main"];
    }
}

- (void)onModuleRegister:(ThrioModuleContext *)moduleContext {
}

- (void)onModuleInit:(ThrioModuleContext *)moduleContext {
}

- (void)onModuleAsyncInit:(ThrioModuleContext *)moduleContext {
}

- (void)startupFlutterEngineWithEntrypoint:(NSString *)entrypoint {
    __weak typeof(self) weakself = self;
    ThrioIdCallback readyBlock = ^(id entrypoint) {
        __strong typeof(weakself) strongSelf = weakself;
        NSMutableDictionary *canTransParams = [NSMutableDictionary dictionary];
        for (NSString *key in strongSelf.moduleContext.params) {
            id value = strongSelf.moduleContext.params[key];
            value = [ThrioModule serializeParams:value];
            if ([value canTransToFlutter]) {
                canTransParams[key] = value;
            }
        }
        if (canTransParams.count > 0) {
            ThrioChannel *moduleContextChannel = [NavigatorFlutterEngineFactory.shared getModuleChannelByEntrypoint:entrypoint];
            [moduleContextChannel invokeMethod:@"set" arguments:canTransParams];
        }
    };
    [NavigatorFlutterEngineFactory.shared startupWithEntrypoint:entrypoint
                                                     readyBlock:readyBlock];
}

@end
