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
#import "NavigatorLogger.h"
#import "ThrioNavigator.h"
#import "NavigatorRouteObserverChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorFlutterEngine ()

@property (nonatomic, strong, readwrite, nullable) FlutterEngine *engine;

@property (nonatomic, strong, nullable) ThrioChannel *channel;

@property (nonatomic, strong, readwrite, nullable) NavigatorRouteReceiveChannel *receiveChannel;

@property (nonatomic, strong, readwrite, nullable) NavigatorRouteSendChannel *sendChannel;

@property (nonatomic, strong) NavigatorRouteObserverChannel *routeObserverChannel;

@property (nonatomic, strong, readwrite, nullable) NavigatorPageObserverChannel *pageObserverChannel;

@property (nonatomic, strong) NSMutableArray *flutterViewControllers;

@end

@implementation NavigatorFlutterEngine

- (void)startupWithEntrypoint:(NSString *)entrypoint
                   readyBlock:(ThrioIdCallback _Nullable)block {
  if (!_engine) {
    _flutterViewControllers = [NSMutableArray array];
    [self startupFlutterWithEntrypoint:entrypoint];
    [self registerPlugins];
    [self setupChannelWithEntrypoint:entrypoint readyBlock:block];
  }
}

- (void)pushViewController:(NavigatorFlutterViewController *)viewController {
  if (![_flutterViewControllers containsObject:viewController]) {
    [_flutterViewControllers addObject:viewController];
  }
  NavigatorVerbose(@"NavigatorFlutterEngine: enter pushViewController");
  if (_engine.viewController != viewController && viewController != nil) {
    [_flutterViewControllers removeObject:viewController];
    NavigatorVerbose(@"NavigatorFlutterEngine: set new %@", viewController);
    _engine.viewController = nil;
    _engine.viewController = viewController;
    [(NavigatorFlutterViewController*)_engine.viewController surfaceUpdated:YES];
    
  }
}

- (NSUInteger)popViewController:(NavigatorFlutterViewController *)viewController {
  [_flutterViewControllers removeObject:viewController];
  NavigatorVerbose(@"NavigatorFlutterEngine: enter popViewController");
  if (_engine.viewController == viewController && viewController != nil) {
    NavigatorVerbose(@"NavigatorFlutterEngine: unset %@", viewController);
    _engine.viewController = nil;
    _engine.viewController = _flutterViewControllers.lastObject;
    if (_engine.viewController) {
      [(NavigatorFlutterViewController*)_engine.viewController surfaceUpdated:YES];
    }
  }
  return _flutterViewControllers.count;
}

#pragma mark - private methods

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

- (void)registerPlugins {
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

- (void)setupChannelWithEntrypoint:(NSString *)entrypoint
                        readyBlock:(ThrioIdCallback _Nullable)block {
  _channel = [ThrioChannel channelWithEntrypoint:entrypoint name:@"__thrio_app__"];
  
  [_channel setupEventChannel:_engine.binaryMessenger];
  [_channel setupMethodChannel:_engine.binaryMessenger];

  _receiveChannel = [[NavigatorRouteReceiveChannel alloc] initWithChannel:_channel];
  [_receiveChannel setReadyBlock:block];
  
  _sendChannel = [[NavigatorRouteSendChannel alloc] initWithChannel:_channel];

  ThrioChannel *routeChannel = [ThrioChannel channelWithEntrypoint:entrypoint name:@"__thrio_route_channel__"];
  [routeChannel setupMethodChannel:_engine.binaryMessenger];
  _routeObserverChannel = [[NavigatorRouteObserverChannel alloc] initWithChannel:routeChannel];
  
  ThrioChannel *pageChannel = [ThrioChannel channelWithEntrypoint:entrypoint name:@"__thrio_page_channel__"];
  [pageChannel setupMethodChannel:_engine.binaryMessenger];
  _pageObserverChannel = [[NavigatorPageObserverChannel alloc] initWithChannel:pageChannel];
}

- (void)dealloc {
  NavigatorVerbose(@"NavigatorFlutterEngine: dealloc %@", self);
  if (_engine) {
    _engine.viewController = nil;
    [_engine destroyContext];
    _engine = nil;
  }
}

@end

NS_ASSUME_NONNULL_END
