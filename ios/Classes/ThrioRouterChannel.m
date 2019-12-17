//
//  ThrioRouterChannel.m
//  Pods-Runner
//
//  Created by foxsofter on 2019/12/9.
//

#import <Flutter/Flutter.h>

#import "ThrioRouterChannel.h"
#import "Registry/ThrioRegistryMap.h"
#import "Registry/ThrioRegistrySetMap.h"
#import "ThrioRouter.h"

@interface ThrioRouterChannel ()

@property (nonatomic, copy) NSString *channelName;

@property (nonatomic, strong) NSObject<FlutterBinaryMessenger> *messenger;

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;

@property (nonatomic, strong) ThrioRegistryMap *methodHandlers;

@property (nonatomic, strong) FlutterEventChannel *eventChannel;

@property (nonatomic, strong) ThrioRegistrySetMap *eventHandlers;

@property (nonatomic, strong) FlutterEventSink eventSink;

@end

static NSString *const kDefaultChannelName = @"__thrio_router__";

static NSString *const kEventNameKey = @"__event_name__";

@implementation ThrioRouterChannel

+ (instancetype)channelWithName {
  return [self channelWithName:@""];
}

+ (instancetype)channelWithName:(NSString *)channelName {
  if (!channelName || channelName.length < 1) {
    channelName = kDefaultChannelName;
  }
  id instance = [[self instanceCaches] valueForKey:channelName];
  if (!instance) {
    instance = [[ThrioRouterChannel alloc] initWithName:channelName
                                        binaryMessenger:[ThrioRouter.router registarar].messenger];
    [[self instanceCaches] setValue:instance forKey:channelName];
  }
  return instance;
}

- (instancetype)initWithName:(NSString *)channelName
             binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  self = [super init];
  if (self) {
    _channelName = channelName;
    _messenger = messenger;
  }
  return self;
}

#pragma mark - method channel methods

- (void)invokeMethod:(NSString*)method
           arguments:(id _Nullable)arguments {
  [self setupMethodChannelIfNeeded];
  return [_methodChannel invokeMethod:method
                            arguments:arguments];
}

- (void)invokeMethod:(NSString*)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback {
  [self setupMethodChannelIfNeeded];
  return [_methodChannel invokeMethod:method
                            arguments:arguments
                               result:callback];
}

- (ThrioVoidCallback)registryMethodCall:(NSString *)method
                                handler:(ThrioMethodHandler)handler {
  [self setupMethodChannelIfNeeded];
  return [_methodHandlers registry:method value:handler];
}

#pragma mark - event channel methods

- (void)sendEvent:(NSString *)name arguments:(id _Nullable)arguments {
  [self setupEventChannelIfNeeded];
  if (self.eventSink) {
    id args = [NSMutableDictionary dictionaryWithDictionary:arguments];
    [args setValue:name forKey:kEventNameKey];
    self.eventSink(args);
  }
}

- (ThrioVoidCallback)registryEventHandling:(NSString *)name
                                   handler:(ThrioEventHandler)handler {
  [self setupEventChannelIfNeeded];
  return [_eventHandlers registry:name value:handler];
}

#pragma mark - FlutterStreamHandler methods

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments
                                        eventSink:(nonnull FlutterEventSink)events {
  self.eventSink = events;
  return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  return nil;
}

#pragma mark - helper methods

+ (NSMutableDictionary *)instanceCaches {
  static NSMutableDictionary *instanceCaches_;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instanceCaches_ = [NSMutableDictionary new];
  });
  return instanceCaches_;
};

- (void)setupMethodChannelIfNeeded {
  if (_methodChannel) {
    return;
  }
  _methodHandlers = [ThrioRegistryMap map];
  
  NSString *methodChannelName = [NSString stringWithFormat:@"_method_%@", _channelName];
  _methodChannel = [FlutterMethodChannel methodChannelWithName:methodChannelName
                                               binaryMessenger:_messenger];
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

- (void)setupEventChannelIfNeeded {
  if (_eventChannel) {
    return;
  }
  _eventHandlers = [ThrioRegistrySetMap map];
  
  NSString *eventChannelName = [NSString stringWithFormat:@"_event_%@", _channelName];
  _eventChannel = [FlutterEventChannel eventChannelWithName:eventChannelName
                                            binaryMessenger:_messenger];
  [_eventChannel setStreamHandler:self];
}

@end
