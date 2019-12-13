//
//  ThrioRouterChannel.m
//  Pods-Runner
//
//  Created by Wei ZhongDan on 2019/12/9.
//

#import <Flutter/Flutter.h>

#import "ThrioRouterChannel.h"
#import "registry/ThrioRegistryMap.h"

@interface ThrioRouterChannel ()

@property (nonatomic, strong) FlutterMethodChannel *channel;

@property (nonatomic, strong) ThrioRegistryMap *handlers;

@end

static NSString *const kDefaultChannelName = @"__thrio_router__";

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
    _handlers = [ThrioRegistryMap map];
    _channel = [FlutterMethodChannel methodChannelWithName:channelName
                                            binaryMessenger:messenger];
    __weak typeof(self) weakself = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call,
                                     FlutterResult  _Nonnull result) {
      __strong typeof(self) strongSelf = weakself;
      ThrioMethodHandler handler = strongSelf.handlers[call.method];
      id resultData = handler(call.arguments);
      if (resultData) {
        result(resultData);
      }
    }];
  }
  return self;
}

- (void)invokeMethod:(NSString*)method arguments:(id _Nullable)arguments {
  return [_channel invokeMethod:method arguments:arguments];
}

- (void)invokeMethod:(NSString*)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback {
  return [_channel invokeMethod:method arguments:arguments result:callback];
}

- (ThrioVoidCallback)registryMethodHandler:(NSString *)method
                                   handler:(ThrioMethodHandler)handler {
  return [_handlers registry:method value:handler];
}


+ (NSMutableDictionary *)instanceCaches {
  static NSMutableDictionary *_instanceCaches;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _instanceCaches = [NSMutableDictionary new];
  });
  return _instanceCaches;
};

@end
