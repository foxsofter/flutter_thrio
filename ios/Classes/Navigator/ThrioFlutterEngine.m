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
