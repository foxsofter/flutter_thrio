//
//  NavigatorSendChannel.m
//  thrio
//
//  Created by fox softer on 2020/3/16.
//

#import "NavigatorSendChannel.h"

@interface NavigatorSendChannel ()

@property (nonatomic, strong) ThrioChannel *channel;

@end

@implementation NavigatorSendChannel

- (instancetype)initWithChannel:(ThrioChannel *)channel {
  self = [super init];
  if (self) {
    _channel = channel;
  }
  return self;
}

- (void)onPush:(id _Nullable)arguments result:(FlutterResult _Nullable)callback {
  [self _on:@"onPush" arguments:arguments result:callback];
}

- (void)onNotify:(id _Nullable)arguments result:(FlutterResult _Nullable)callback {
  [self _on:@"onNotify" arguments:arguments result:callback];
}

- (void)onPop:(id _Nullable)arguments result:(FlutterResult _Nullable)callback {
  [self _on:@"onPop" arguments:arguments result:callback];
}

- (void)onPopTo:(id _Nullable)arguments result:(FlutterResult _Nullable)callback {
  [self _on:@"onPopTo" arguments:arguments result:callback];
}

- (void)onRemove:(id _Nullable)arguments result:(FlutterResult _Nullable)callback {
  [self _on:@"onRemove" arguments:arguments result:callback];
}

- (void)_on:(NSString *)method
  arguments:(id _Nullable)arguments
     result:(FlutterResult _Nullable)callback {
  NSString *channelMethod = [NSString stringWithFormat:@"__%@__", method];
  [_channel invokeMethod:channelMethod arguments:arguments result:callback];
}

@end
