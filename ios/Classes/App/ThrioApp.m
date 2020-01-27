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
#import "UIViewController+ThrioPageRoute.h"
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

- (void)onSyncInit {
  [self _startupOnce];
}

- (void)onAsyncInit {
  _emptyViewController = [[ThrioFlutterViewController alloc] init];
  [self _onPush];
  [self _onNotify];
  [self _onPop];
  [self _onPopTo];
  [self _onRemove];
  [self _onLastIndex];
  [self _onGetAllIndex];
}

#pragma mark - ThrioNavigatorProtocol methods

- (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params
       animated:(BOOL)animated
         result:(ThrioBoolCallback)result {
  [self _startupOnce];

  if ([self canPushUrl:url params:params]) {
    [self.navigationController thrio_pushUrl:url
                                      params:params
                                    animated:animated
                                      result:^(BOOL r) {
      result(r);
    }];
  }
}

- (BOOL)canPushUrl:(NSString *)url params:(NSDictionary * _Nullable)params {
  return self.navigationController != nil;
}

- (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           params:(NSDictionary *)params
           result:(ThrioBoolCallback)result {
  BOOL canNotify = [self canNotifyUrl:url index:index];
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

- (BOOL)canNotifyUrl:(NSString *)url index:(NSNumber * _Nullable)index {
  return [self.navigationController thrio_ContainsUrl:url index:index];
}

- (void)popAnimated:(BOOL)animated result:(ThrioBoolCallback)result {
  if ([self canPop]) {
    [self.navigationController thrio_popAnimated:animated result:^(BOOL r) {
      result(r);
    }];
  }
}

- (BOOL)canPop {
  UINavigationController *nvc = self.navigationController;
  return nvc.viewControllers.count > 1 ||
         nvc.topViewController.firstRoute != nvc.topViewController.lastRoute;
}

- (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
        animated:(BOOL)animated
          result:(ThrioBoolCallback)result {
  if ([self canRemoveUrl:url index:index]) {
    [self.navigationController thrio_popToUrl:url
                                        index:index
                                     animated:animated
                                       result:^(BOOL r) {
      result(r);
    }];
  }
}

- (BOOL)canPopToUrl:(NSString *)url index:(NSNumber * _Nullable)index {
  return [self.navigationController thrio_ContainsUrl:url index:index];
}

- (void)removeUrl:(NSString *)url
            index:(NSNumber *)index
         animated:(BOOL)animated
           result:(ThrioBoolCallback)result {
  if ([self canRemoveUrl:url index:index]) {
    [self.navigationController thrio_removeUrl:url
                                         index:index
                                      animated:animated
                                        result:^(BOOL r) {
      result(r);
    }];
  }
}

- (BOOL)canRemoveUrl:(NSString *)url index:(NSNumber * _Nullable)index {
  return [self.navigationController thrio_ContainsUrl:url index:index];
}

- (NSNumber *)lastIndex {
  return [self.navigationController thrio_lastIndex];
}

- (NSNumber *)getLastIndexByUrl:(NSString *)url {
  return [self.navigationController thrio_getLastIndexByUrl:url];
}

- (NSArray *)getAllIndexByUrl:(NSString *)url {
  return [self.navigationController thrio_getAllIndexByUrl:url];
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
     [self notifyUrl:url index:index name:name params:params result:^(BOOL r) {
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
    [self pushUrl:url params:params animated:animated result:^(BOOL r) {
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
     BOOL animated = [arguments[@"animated"] boolValue];
     [self popAnimated:animated result:^(BOOL r) {
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
    [self popToUrl:url index:index animated:animated result:^(BOOL r) {
      if (result) {
        result(r);
      }
    }];
  }];
}

- (void)_onRemove {
   [_channel registryMethodCall:@"remove"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];
    BOOL animated = [arguments[@"animated"] boolValue];
    [self removeUrl:url index:index animated:animated result:^(BOOL r) {
      if (result) {
        result(r);
      }
    }];
  }];
}

- (void)_onLastIndex {
   [_channel registryMethodCall:@"lastIndex"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    if (result) {
      NSNumber *index = @0;
      if (url.length < 1) {
        result([self lastIndex]);
      } else {
        result([self getLastIndexByUrl:url]);
      }
    }
  }];
}

- (void)_onGetAllIndex {
   [_channel registryMethodCall:@"allIndex"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
     NSString *url = arguments[@"url"];
     if (result) {
       result([self getAllIndexByUrl:url]);
     }
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
