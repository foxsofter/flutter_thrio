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
#import "ThrioPageObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioApp ()

@property (nonatomic, strong, readwrite) ThrioChannel *channel;

@property (nonatomic, strong, readwrite) FlutterEngine *engine;

@property (nonatomic, strong) ThrioFlutterViewController *emptyViewController;

@property (nonatomic, strong) ThrioPageObserver *pageObserver;

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
  ThrioLogV(@"enter attach flutter view controller");
  if (_engine.viewController != viewController) {
    ThrioLogV(@"attach new flutter view controller");
    [(ThrioFlutterViewController*)_engine.viewController surfaceUpdated:NO];
    _engine.viewController = viewController;
//    [self _shouldPauseOrResume];
  }
}

- (void)detachFlutterViewController:(ThrioFlutterViewController *)viewController {
  ThrioLogV(@"enter detach flutter view controller");
  if (_engine.viewController == viewController) {
    ThrioLogV(@"detach flutter view controller");
    _engine.viewController = _emptyViewController;
//    [self _shouldPauseOrResume];
  }
}

- (void)onSyncInit {
  [self _startupOnce];
}

- (void)onAsyncInit {
  _emptyViewController = [[ThrioFlutterViewController alloc] init];
  _pageObserver = [[ThrioPageObserver alloc] initWithChannel:_channel];
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
  return (nvc.viewControllers.count > 1 ||
          nvc.topViewController.thrio_firstRoute != nvc.topViewController.thrio_lastRoute) &&
         !nvc.topViewController.thrio_lastRoute.popDisabled;
}

- (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
        animated:(BOOL)animated
          result:(ThrioBoolCallback)result {
  if ([self canPopToUrl:url index:index]) {
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

- (void)setPopDisabledUrl:(NSString *)url index:(NSNumber *)index disabled:(BOOL)disabled {
  return[self.navigationController thrio_setPopDisabledUrl:url index:index disabled:disabled];
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
  NSInteger count = 0;
  NSArray *vcs = [self.navigationController.viewControllers copy];
  for (id vc in vcs) {
    if ([vc isKindOfClass:ThrioFlutterViewController.class]) {
      count++;
    }
  }
  if (count == 0) {
    // Set flutter app to `AppLifecycleState.paused`
    [ThrioLogger v:@"AppLifecycleState.paused"];
    [self.engine.lifecycleChannel sendMessage:@"AppLifecycleState.paused"];
  } else {
    // Set flutter app to `AppLifecycleState.resumed`
    [ThrioLogger v:@"AppLifecycleState.resumed"];
//      [self.engine.lifecycleChannel sendMessage:@"AppLifecycleState.resumed"];
  }
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
