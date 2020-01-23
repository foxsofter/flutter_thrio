//
//  ThrioApp.m
//  thrio
//
//  Created by foxsofter on 2019/12/19.
//

#import "ThrioApp.h"
#import "ThrioFlutterViewController.h"
#import "ThrioException.h"
#import "ThrioChannel.h"
#import "ThrioPlugin.h"
#import "UIApplication+Thrio.h"
#import "UINavigationController+ThrioNavigator.h"
#import "ThrioLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioApp ()

@property (nonatomic, strong, readwrite) ThrioChannel *channel;

@property (nonatomic, strong, readwrite) FlutterEngine *engine;

@property (nonatomic, strong) ThrioFlutterViewController *emptyViewController;

@end

@implementation ThrioApp

+ (instancetype)shared {
  static ThrioApp *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[ThrioApp alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _channel = [ThrioChannel channelWithName:@"__thrio_app__"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_appWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_appDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
  }
  return self;
}

#pragma mark - public properties

- (UINavigationController * _Nullable)navigationController {
  return [[UIApplication sharedApplication] topmostNavigationController];
}

- (ThrioFlutterViewController *)flutterViewController {
  if (_engine.viewController != _emptyViewController) {
    return (ThrioFlutterViewController*)_engine.viewController;
  }
  return nil;
}

- (void)attachFlutterViewController:(ThrioFlutterViewController *)viewController {
  if (_engine.viewController != viewController) {
    [(ThrioFlutterViewController*)_engine.viewController surfaceUpdated:NO];
    _engine.viewController = viewController;
    [self _shouldPauseOrResume];
  }
}

- (void)detachFlutterViewController {
  if (_engine.viewController != _emptyViewController) {
    _engine.viewController = _emptyViewController;
    [self _shouldPauseOrResume];
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationWillEnterForegroundNotification
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationDidEnterBackgroundNotification
                                                object:nil];
}

- (void)onSyncInit {
  [self _startupOnce];
}

- (void)onAsyncInit {
  _emptyViewController = [[ThrioFlutterViewController alloc] init];
  [self _onNotify];
  [self _onPush];
  [self _onPop];
  [self _onPopTo];
}

#pragma mark - ThrioNavigatorProtocol methods

- (void)push:(NSString *)url
      params:(NSDictionary *)params
    animated:(BOOL)animated
      result:(ThrioBoolCallback)result {
  [self _startupOnce];

  BOOL canPush = [self canPush:url params:params];
  if (canPush) {
    canPush = [self.navigationController thrio_pushUrl:url
                                                params:params
                                              animated:animated];
  }
  if (result) {
    result(canPush);
  }
}

- (BOOL)canPush:(NSString *)url params:(NSDictionary * _Nullable)params {
  return self.navigationController != nil;
}

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index
        params:(NSDictionary *)params
        result:(ThrioBoolCallback)result {
  BOOL canNotify = [self canNotify:url index:index];
  if (canNotify) {
    canNotify = [self.navigationController thrio_notifyUrl:url
                                                     index:index
                                                      name:name
                                                    params:params];
  }
  if (result) {
    result(canNotify);
  }
}

- (BOOL)canNotify:(NSString *)url index:(NSNumber * _Nullable)index {
  return [self.navigationController thrio_ContainsUrl:url index:index];
}

- (void)pop:(NSString *)url
      index:(NSNumber *)index
   animated:(BOOL)animated
     result:(ThrioBoolCallback)result {
  BOOL canPop = [self canPop:url index:index];
  if (canPop) {
    canPop = [self.navigationController thrio_popUrl:url
                                               index:index
                                            animated:animated];
  }
  if (result) {
    result(canPop);
  }
}

- (BOOL)canPop:(NSString *)url index:(NSNumber * _Nullable)index {
  return url.length < 1 || [self.navigationController thrio_ContainsUrl:url index:index];
}

- (void)popTo:(NSString *)url
        index:(NSNumber *)index
     animated:(BOOL)animated
       result:(ThrioBoolCallback)result {
  BOOL canPopTo = [self canPop:url index:index];
  if (canPopTo) {
    canPopTo = [self.navigationController thrio_popToUrl:url
                                                   index:index
                                                animated:animated];
  }
  if (result) {
    result(canPopTo);
  }
}

- (BOOL)canPopTo:(NSString *)url index:(NSNumber * _Nullable)index {
  return [self.navigationController thrio_ContainsUrl:url index:index];
}

#pragma mark - registry methods

- (ThrioVoidCallback)registerNativeViewControllerBuilder:(ThrioNativeViewControllerBuilder)builder
                                        forUrl:(NSString *)url {
  return [self.navigationController thrio_registerNativeViewControllerBuilder:builder forUrl:url];
}

- (ThrioVoidCallback)registerFlutterViewControllerBuilder:(ThrioFlutterViewControllerBuilder)builder {
  return [self.navigationController thrio_registerFlutterViewControllerBuilder:builder];
}

#pragma mark - private methods

- (void)_appWillEnterForeground {
  [self.flutterViewController sendPageLifecycleEvent:ThrioPageLifecycleForeground];
}

- (void)_appDidEnterBackground {
  [_emptyViewController sendPageLifecycleEvent:ThrioPageLifecycleBackground];
}

- (void)_shouldPauseOrResume {
  NSInteger flutterPageCount = 0;
  NSArray *vcs = [_engine.viewController.navigationController.viewControllers copy];
  for (id vc in vcs) {
    if ([vc isKindOfClass:ThrioFlutterViewController.class]) {
      flutterPageCount++;
    }
  }
  if (flutterPageCount == 0) {
    // Set flutter app to `AppLifecycleState.paused`
    [ThrioLogger v:@"AppLifecycleState.paused"];
    [_engine.lifecycleChannel sendMessage:@"AppLifecycleState.paused"];
  } else {
    // Set flutter app to `AppLifecycleState.resumed`
    [ThrioLogger v:@"AppLifecycleState.resumed"];
    [_engine.lifecycleChannel sendMessage:@"AppLifecycleState.resumed"];
  }
}

- (void)_onNotify {
  [_channel registryMethodCall:@"notify"
                       handler:^void(NSDictionary<NSString *,id> * arguments,
                                     ThrioBoolCallback _Nullable result) {
    NSString *name = arguments[@"name"];
    if (name.length < 1) {
      if (result) {
        result(NO);
      }
      return;
    }
    NSString *url = arguments[@"url"];
    if (url.length < 1) {
      if (result) {
        result(NO);
      }
      return;
    }
    NSNumber *index = arguments[@"index"];
    NSDictionary *params = arguments[@"params"];
     [self notify:name url:url index:index params:params result:^(BOOL r) {
       if (result) {
         result(r);
       }
    }];
  }];
}

- (void)_onPush {
   [_channel registryMethodCall:@"push"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    if (url.length < 1) {
      if (result) {
        result(NO);
      }
      return;
    }
    BOOL animated = [arguments[@"animated"] boolValue];
    NSDictionary *params = arguments[@"params"];
    [self push:url params:params animated:animated result:^(BOOL r) {
      if (result) {
        result(r);
      }
    }];
  }];
}

- (void)_onPop {
   [_channel registryMethodCall:@"pop"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];
    BOOL animated = [arguments[@"animated"] boolValue];
    [self pop:url index:index animated:animated result:^(BOOL r) {
      if (result) {
        result(r);
      }
    }];
  }];
}

- (void)_onPopTo {
   [_channel registryMethodCall:@"popTo"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    if (url.length < 1) {
      if (result) {
        result(NO);
      }
      return;
    }
    NSNumber *index = arguments[@"index"];
    BOOL animated = [arguments[@"animated"] boolValue];
    [self popTo:url index:index animated:animated result:^(BOOL r) {
      if (result) {
        result(r);
      }
    }];
  }];
}

- (void)_startupOnce {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self _startupFlutter];
    [self _registerPlugin];
  });
}

- (void)_startupFlutter {
  _engine = [[FlutterEngine alloc] initWithName:@"io.flutter" project:nil];
  BOOL result = [_engine run];
  if (!result) {
    @throw [ThrioException exceptionWithName:@"FlutterFailedException"
                                      reason:@"run flutter engine failed!"
                                    userInfo:nil];
  }
}

- (void)_registerPlugin {
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

@end

NS_ASSUME_NONNULL_END
