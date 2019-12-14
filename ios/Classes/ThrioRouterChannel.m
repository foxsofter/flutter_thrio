//
//  ThrioRouterChannel.m
//  Pods-Runner
//
//  Created by Wei ZhongDan on 2019/12/9.
//

#import <Flutter/Flutter.h>

#import "ThrioRouterChannel.h"
#import "registry/ThrioRegistryMap.h"
#import "registry/ThrioRegistrySetMap.h"

@interface ThrioRouterChannel ()

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;

@property (nonatomic, strong) ThrioRegistryMap *methodHandlers;

@property (nonatomic, strong) FlutterEventChannel *eventChannel;

@property (nonatomic, strong) ThrioRegistrySetMap *eventHandlers;

@property (nonatomic, strong) FlutterEventSink eventSink;

@end

static NSString *const kDefaultChannelName = @"__thrio_router__";

static NSString *const kEventNameKey = @"__event_name__";

@implementation ThrioRouterChannel

+ (instancetype)channelWithName:(NSString *)channelName
                binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  if (!channelName) {
    channelName = kDefaultChannelName;
  }
  id instance = [[self instanceCaches] valueForKey:channelName];
  if (!instance) {
    instance = [[ThrioRouterChannel alloc] initWithName:channelName
                                        binaryMessenger:messenger];
    [[self instanceCaches] setValue:instance forKey:channelName];
  }
  return instance;
}

- (instancetype)initWithName:(NSString *)channelName
             binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  self = [super init];
  if (self) {
    [self setupMethodChannel:channelName messenger:messenger];
    [self setupEventChannel:channelName messenger:messenger];
  }
  return self;
}

- (void)invokeMethod:(NSString*)method
           arguments:(id _Nullable)arguments {
  return [_methodChannel invokeMethod:method
                            arguments:arguments];
}

- (void)invokeMethod:(NSString*)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback {
  return [_methodChannel invokeMethod:method
                            arguments:arguments
                               result:callback];
}

- (ThrioVoidCallback)registryMethodCall:(NSString *)method
                                handler:(ThrioMethodHandler)handler {
  return [_methodHandlers registry:method value:handler];
}

- (void)sendEvent:(NSString *)name arguments:(id _Nullable)arguments {
  if (self.eventSink) {
    id args = [NSMutableDictionary dictionaryWithDictionary:arguments];
    [args setValue:name forKey:kEventNameKey];
    self.eventSink(args);
  }
}

- (ThrioVoidCallback)registryEventHandling:(NSString *)name
                                   handler:(ThrioEventHandler)handler {
  return [_eventHandlers registry:name value:handler];
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments
                                        eventSink:(nonnull FlutterEventSink)events {
  self.eventSink = events;
  return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  return nil;
}


+ (NSMutableDictionary *)instanceCaches {
  static NSMutableDictionary *_instanceCaches;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _instanceCaches = [NSMutableDictionary new];
  });
  return _instanceCaches;
};

- (void)setupMethodChannel:(NSString *)channelName
                 messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  _methodHandlers = [ThrioRegistryMap map];
  
  NSString *methodChannelName = [NSString stringWithFormat:@"_method_%@", channelName];
  _methodChannel = [FlutterMethodChannel methodChannelWithName:methodChannelName
                                               binaryMessenger:messenger];
  __weak typeof(self) weakself = self;
  [_methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call,
                                         FlutterResult  _Nonnull result) {
    __strong typeof(self) strongSelf = weakself;
    ThrioMethodHandler handler = strongSelf.methodHandlers[call.method];
    id resultData = handler(call.arguments);
    if (resultData) {
      result(resultData);
    }
  }];
}

- (void)setupEventChannel:(NSString *)channelName
                messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  _eventHandlers = [ThrioRegistrySetMap map];
  
  NSString *eventChannelName = [NSString stringWithFormat:@"_event_%@", channelName];
  _eventChannel = [FlutterEventChannel eventChannelWithName:eventChannelName
                                            binaryMessenger:messenger];
  [_eventChannel setStreamHandler:self];
}

@end
