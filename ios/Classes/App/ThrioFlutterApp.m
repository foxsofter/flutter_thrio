//
//  ThrioFlutterApp.m
//  thrio
//
//  Created by foxsofter on 2019/12/19.
//

#import <Flutter/Flutter.h>
#import "ThrioFlutterApp.h"
#import "ThrioFlutterPage.h"

@interface ThrioFlutterApp ()

@property (nonatomic, strong, readwrite) FlutterEngine *engine;

@property (nonatomic, strong) ThrioFlutterPage *emptyPage;

@end

@implementation ThrioFlutterApp

+ (instancetype)shared {
  static ThrioFlutterApp *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[ThrioFlutterApp alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _engine = [[FlutterEngine alloc] initWithName:@"__thrio__"];
    
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

- (ThrioFlutterPage *)page {
  if (_engine.viewController != _emptyPage) {
    return (ThrioFlutterPage*)_engine.viewController;
  }
  return nil;
}

- (void)attachPage:(ThrioFlutterPage *)page {
  if (_engine.viewController != page) {
    [(ThrioFlutterPage*)_engine.viewController surfaceUpdated:NO];
    _engine.viewController = page;
    [self _shouldPauseOrResume];
  }
}

- (void)detachPage {
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
