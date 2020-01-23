//
//  ThrioFlutterViewController.m
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioFlutterViewController.h"
#import "UIViewController+ThrioPageRoute.h"
#import "ThrioApp.h"
#import "ThrioChannel.h"

NS_ASSUME_NONNULL_BEGIN

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation ThrioFlutterViewController

- (instancetype)init {
  self = [super initWithEngine:[ThrioApp.shared engine] nibName:nil bundle:nil];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = UIColor.whiteColor;
}

- (void)viewDidLayoutSubviews {
  
  [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {

  [self sendPageLifecycleEvent:ThrioPageLifecycleWillAppear];

  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  if (self.firstRoute == self.lastRoute) {
    [ThrioApp.shared attachFlutterViewController:self];
  }
  
  [self sendPageLifecycleEvent:ThrioPageLifecycleAppeared];

  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  
  [[UIApplication sharedApplication].delegate.window endEditing:YES];

  [self sendPageLifecycleEvent:ThrioPageLifecycleWillDisappeared];

  [super viewWillDisappear:animated];
}

- (void)dealloc {
  [self sendPageLifecycleEvent:ThrioPageLifecycleDestroyed];
}

// override
- (void)installSplashScreenViewIfNecessary {
  //Do nothing.
}

// override
- (BOOL)loadDefaultSplashScreenView {
  return NO;
}

- (void)sendPageLifecycleEvent:(ThrioPageLifecycle)lifecycle {
  if (self.lastRoute.settings.url.length < 1) {
    return;
  }
  NSDictionary *arguments = @{
    @"url": self.lastRoute.settings.url,
    @"index": self.lastRoute.settings.index,
  };
  NSString *name = [self _pageLifecycleToString:lifecycle];
  [[ThrioApp.shared channel] sendEvent:name arguments:arguments];
}

#pragma mark - private methods

// Convert ThrioPageLifecycle to the corresponding dart enumeration string.
//
- (NSString *)_pageLifecycleToString:(ThrioPageLifecycle)lifecycle {
  switch (lifecycle) {
    case ThrioPageLifecycleInited:
      return @"PageLifecycle.inited";
    case ThrioPageLifecycleWillAppear:
      return @"PageLifecycle.willAppear";
    case ThrioPageLifecycleAppeared:
      return @"PageLifecycle.appeared";
    case ThrioPageLifecycleWillDisappeared:
      return @"PageLifecycle.willDisappear";
    case ThrioPageLifecycleDisappeared:
      return @"PageLifecycle.disappeared";
    case ThrioPageLifecycleDestroyed:
      return @"PageLifecycle.destroyed";
    default:
      return nil;
  }
}

@end
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_END
