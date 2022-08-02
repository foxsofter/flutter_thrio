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

#import <Flutter/Flutter.h>

#import "NavigatorFlutterEngineFactory.h"
#import "ThrioChannel.h"
#import "FlutterThrioPlugin.h"
#import "ThrioRegistryMap.h"
#import "ThrioRegistrySetMap.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioChannel ()

@property (nonatomic, copy) NSString *channelName;

@property (nonatomic, copy, readwrite) NSString *entrypoint;

@property (nonatomic, strong) NSObject<FlutterBinaryMessenger> *messenger;

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;

@property (nonatomic, strong) ThrioRegistryMap *methodHandlers;

@property (nonatomic, strong) FlutterEventChannel *eventChannel;

@property (nonatomic, strong) ThrioRegistrySetMap *eventHandlers;

@property (nonatomic, strong) FlutterEventSink eventSink;

@end

static NSString *const kDefaultChannelName = @"__thrio__";

static NSString *const kEventNameKey = @"__event_name__";

@implementation ThrioChannel

+ (instancetype)channelWithEntrypoint:(NSString *)entrypoint {
    return [self channelWithEntrypoint:entrypoint name:kDefaultChannelName];
}

+ (instancetype)channelWithEntrypoint:(NSString *)entrypoint name:(NSString *)channelName {
    if (!channelName || channelName.length < 1) {
        channelName = kDefaultChannelName;
    }
    return [[ThrioChannel alloc] initWithEntrypoint:entrypoint name:channelName];
}

- (instancetype)initWithEntrypoint:(NSString *)entrypoint name:(NSString *)channelName {
    self = [super init];
    if (self) {
        if (NavigatorFlutterEngineFactory.shared.multiEngineEnabled &&
            [entrypoint isEqualToString:@"main"]) {
            [NSException raise:@"ThrioException"
                        format:@"multi-engine mode, entrypoint should not be main."];
        }
        _entrypoint = entrypoint;
        _channelName = channelName;
    }
    return self;
}

#pragma mark - method channel methods

- (void)invokeMethod:(NSString *)method {
    return [_methodChannel invokeMethod:method arguments:nil result:nil];
}

- (void)invokeMethod:(NSString *)method result:(ThrioIdCallback)callback {
    return [_methodChannel invokeMethod:method arguments:nil result:callback];
}

- (void)invokeMethod:(NSString *)method arguments:(NSDictionary *)arguments {
    return [_methodChannel invokeMethod:method arguments:arguments];
}

- (void)invokeMethod:(NSString *)method
           arguments:(NSDictionary *)arguments
              result:(ThrioIdCallback)callback {
    return [_methodChannel invokeMethod:method
                              arguments:arguments
                                 result:callback];
}

- (ThrioVoidCallback)registryMethod:(NSString *)method
                            handler:(ThrioMethodHandler)handler {
    return [_methodHandlers registry:method value:handler];
}

- (void)setupMethodChannel:(NSObject<FlutterBinaryMessenger> *)messenger {
    _methodHandlers = [ThrioRegistryMap map];

    NSString *methodChannelName = [NSString stringWithFormat:@"_method_%@", _channelName];
    _methodChannel = [FlutterMethodChannel methodChannelWithName:methodChannelName
                                                 binaryMessenger:messenger];
    __weak typeof(self) weakself = self;
    [_methodChannel setMethodCallHandler:
     ^(FlutterMethodCall *_Nonnull call,
       FlutterResult _Nonnull result) {
           __strong typeof(weakself) strongSelf = weakself;
           ThrioMethodHandler handler = strongSelf.methodHandlers[call.method];
           if (handler) {
               @try {
                   handler(call.arguments, ^(id r) {
                               result(r);
                           });
               } @catch (NSException *exception) {
                   [FlutterError errorWithCode:exception.name message:exception.reason details:exception.userInfo];
                   result(nil);
               }
           }
       }];
}

#pragma mark - event channel methods

- (void)sendEvent:(NSString *)name arguments:(NSDictionary *_Nullable)arguments {
    if (self.eventSink) {
        id args = [NSMutableDictionary dictionaryWithDictionary:arguments];
        [args setValue:name forKey:kEventNameKey];
        self.eventSink(args);
    }
}

- (ThrioVoidCallback)registryEvent:(NSString *)name
                           handler:(ThrioEventHandler)handler {
    return [_eventHandlers registry:name value:handler];
}

- (void)setupEventChannel:(NSObject<FlutterBinaryMessenger> *)messenger {
    _eventHandlers = [ThrioRegistrySetMap map];

    NSString *eventChannelName = [NSString stringWithFormat:@"_event_%@", _channelName];
    _eventChannel = [FlutterEventChannel eventChannelWithName:eventChannelName
                                              binaryMessenger:messenger];
    [_eventChannel setStreamHandler:self];
}

#pragma mark - FlutterStreamHandler methods

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
    self.eventSink = events;
    return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
}

@end

NS_ASSUME_NONNULL_END
