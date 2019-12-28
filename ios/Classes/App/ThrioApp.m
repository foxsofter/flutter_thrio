//
//  ThrioApp.m
//  thrio
//
//  Created by foxsofter on 2019/12/19.
//

#import <Flutter/Flutter.h>
#import "ThrioApp.h"
#import "ThrioFlutterPage.h"
#import "ThrioException.h"
#import "ThrioChannel.h"
#import "ThrioPlugin.h"
#import "UIApplication+Thrio.h"
#import "UINavigationController+ThrioRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioApp ()

@property (nonatomic, strong, readwrite) FlutterEngine *engine;

@property (nonatomic, strong) ThrioFlutterPage *emptyPage;

@end

@implementation ThrioApp {
  __weak UINavigationController *_navigationController;
  ThrioFlutterPageBuilder _flutterPageBuilder;
}

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
    _engine = [[FlutterEngine alloc] initWithName:@"io.flutter" project:nil];
    BOOL result = [_engine run];
    if (!result) {
      @throw [ThrioException exceptionWithName:@"FlutterFailedException"
                                        reason:@"run flutter engine failed!"
                                      userInfo:nil];
    }
        
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
  UINavigationController *nvc = [[UIApplication sharedApplication] topmostNavigationController];
  if (_navigationController != nvc) {
    _navigationController = nvc;
    _navigationController.delegate = nvc;
  }
  return _navigationController;
}

- (ThrioFlutterPage * _Nullable)page {
  if (_engine.viewController != _emptyPage) {
    return (ThrioFlutterPage*)_engine.viewController;
  }
  return nil;
}

- (void)attachFlutterPage:(ThrioFlutterPage *)page {
  if (_engine.viewController != page) {
    [(ThrioFlutterPage*)_engine.viewController surfaceUpdated:NO];
    _engine.viewController = page;
    [self _shouldPauseOrResume];
  }
}

- (void)detachFlutterPage {
  if (_engine.viewController != _emptyPage) {
    _engine.viewController = _emptyPage;
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
  [ThrioPlugin registerWithRegistrar:[_engine registrarForPlugin:@"ThrioPlugin"]];
}

#pragma mark - ThrioRouteProtocol methods

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index
        params:(NSDictionary *)params
        result:(ThrioBoolCallback)result {
  BOOL canNotify = [self canNotify:url index:index];
  if (canNotify) {
    canNotify = [self.navigationController notifyPageWithName:name
                                                          url:url
                                                        index:index
                                                       params:params];
  }
  if (result) {
    result(canNotify);
  }
}

- (BOOL)canNotify:(NSString *)url index:(nullable NSNumber *)index {
  return [self.navigationController containsPageWithUrl:url index:index];
}

- (void)push:(NSString *)url
      params:(NSDictionary *)params
    animated:(BOOL)animated
      result:(ThrioBoolCallback)result {
  BOOL canPush = [self canPush:url params:params];
  if (canPush) {
    canPush = [self.navigationController pushPageWithUrl:url
                                                  params:params
                                                animated:animated];
  }
  if (result) {
    result(canPush);
  }
}

- (BOOL)canPush:(NSString *)url params:(nullable NSDictionary *)params {
  return self.navigationController != nil;
}

- (void)pop:(NSString *)url
      index:(NSNumber *)index
   animated:(BOOL)animated
     result:(ThrioBoolCallback)result {
  BOOL canPop = [self canPop:url index:index];
  if (canPop) {
    canPop = [self.navigationController popPageWithUrl:url
                                                 index:index
                                              animated:animated];
  }
  if (result) {
    result(canPop);
  }
}

- (BOOL)canPop:(NSString *)url index:(nullable NSNumber *)index {
  return [self.navigationController containsPageWithUrl:url index:index];
}

- (void)popTo:(NSString *)url
        index:(NSNumber *)index
     animated:(BOOL)animated
       result:(ThrioBoolCallback)result {
  BOOL canPopTo = [self canPop:url index:index];
  if (canPopTo) {
    canPopTo = [self.navigationController popToPageWithUrl:url
                                                     index:index
                                                  animated:animated];
  }
  if (result) {
    result(canPopTo);
  }
}

- (BOOL)canPopTo:(NSString *)url index:(nullable NSNumber *)index {
  return [self.navigationController containsPageWithUrl:url index:index];
}

#pragma mark - registry methods

- (ThrioVoidCallback)registerNativePageBuilder:(ThrioNativePageBuilder)builder
                                        forUrl:(NSString *)url {
  return [self.navigationController registerNativePageBuilder:builder forUrl:url];
}

- (void)setFlutterPageBuilder:(ThrioFlutterPageBuilder)builder {
  [self.navigationController setFlutterPageBuilder:builder];
}

#pragma mark - private methods

- (void)_appWillEnterForeground {
  [_emptyPage sendPageLifecycleEvent:ThrioPageLifecycleForeground];
}

- (void)_appDidEnterBackground {
  [_emptyPage sendPageLifecycleEvent:ThrioPageLifecycleBackground];
}

- (void)_shouldPauseOrResume {
  NSInteger flutterPageCount = 0;
  NSArray *vcs = [_engine.viewController.navigationController.viewControllers copy];
  for (id vc in vcs) {
    if ([vc isKindOfClass:ThrioFlutterPage.class]) {
      flutterPageCount++;
    }
  }
  if (flutterPageCount == 0) {
    // Set flutter app to `AppLifecycleState.paused`
    [_engine.lifecycleChannel sendMessage:@"AppLifecycleState.paused"];
  } else {
    // Set flutter app to `AppLifecycleState.resumed`
    [_engine.lifecycleChannel sendMessage:@"AppLifecycleState.resumed"];
  }
}

@end

NS_ASSUME_NONNULL_END
