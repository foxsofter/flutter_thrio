//
//  ThrioFlutterEngine.m
//  thrio
//
//  Created by fox softer on 2020/2/25.
//

#import "ThrioFlutterEngine.h"
#import "ThrioLogger.h"
#import "ThrioNavigator.h"

@interface ThrioFlutterEngine ()

@property (nonatomic, strong, readwrite, nullable) FlutterEngine *engine;

@property (nonatomic, strong, readwrite, nullable) ThrioChannel *channel;

@property (nonatomic, strong, readwrite, nullable) NavigatorReceiveChannel *receiveChannel;

@end

@implementation ThrioFlutterEngine

- (void)startupWithEntrypoint:(NSString *)entrypoint readyBlock:(ThrioVoidCallback)block {
  if (!_engine) {
    [self startupFlutterWithEntrypoint:entrypoint];
    [self registerPlugin];
    [self setupChannelWithEntrypoint:entrypoint readyBlock:block];
  }
}

- (void)shutdown {
  ThrioLogV(@"ThrioFlutterEngine shutdown: %@", self);
  if (_engine) {
    _engine.viewController = nil;
    [_engine destroyContext];
  }
}

- (void)attachFlutterViewController:(ThrioFlutterViewController *)viewController {
  ThrioLogV(@"enter attach flutter view controller");
  if (_engine.viewController != viewController && viewController != nil) {
    ThrioLogV(@"attach new flutter view controller");
    _engine.viewController = viewController;
    [(ThrioFlutterViewController*)_engine.viewController surfaceUpdated:YES];
  }
}

- (void)detachFlutterViewController:(ThrioFlutterViewController *)viewController {
  ThrioLogV(@"enter detach flutter view controller");
  if (_engine.viewController == viewController && viewController != nil) {
    ThrioLogV(@"detach flutter view controller: %@", _engine);
    [(ThrioFlutterViewController*)_engine.viewController surfaceUpdated:NO];
    _engine.viewController = nil;
  }
}

- (void)startupFlutterWithEntrypoint:(NSString *)entrypoint {
  NSString *enginName = [NSString stringWithFormat:@"io.flutter.%lu", (unsigned long)self.hash];
  _engine = [[FlutterEngine alloc] initWithName:enginName project:nil allowHeadlessExecution:YES];
  BOOL result = NO;
  if (ThrioNavigator.isMultiEngineEnabled) {
    result =[_engine runWithEntrypoint:entrypoint];
  } else {
    result = [_engine run];
  }
  if (!result) {
    @throw [NSException exceptionWithName:@"FlutterFailedException"
                                   reason:@"run flutter engine failed!"
                                 userInfo:nil];
  }
}

- (void)registerPlugin {
  Class clazz = NSClassFromString(@"GeneratedPluginRegistrant");
  if (clazz) {
    if ([clazz respondsToSelector:NSSelectorFromString(@"registerWithRegistry:")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      [clazz performSelector:NSSelectorFromString(@"registerWithRegistry:")
                  withObject:_engine];
#pragma clang diagnostic pop
    }
  }
}

- (void)setupChannelWithEntrypoint:(NSString * _Nonnull)entrypoint
                        readyBlock:(ThrioVoidCallback _Nonnull)block {
  NSString *channelName = [NSString stringWithFormat:@"__thrio_app__%@", entrypoint];
  _channel = [ThrioChannel channelWithName:channelName];
  
  [_channel setupEventChannel:_engine.binaryMessenger];
  [_channel setupMethodChannel:_engine.binaryMessenger];
    
  _receiveChannel = [[NavigatorReceiveChannel alloc] initWithChannel:_channel];
  [_receiveChannel setReadyBlock:block];
}

- (void)dealloc {
  ThrioLogV(@"ThrioFlutterEngine dealloc: %@", self);
}

@end
