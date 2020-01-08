//
//  ThrioFlutterPage.m
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioFlutterPage.h"
#import "UIViewController+ThrioPage.h"
#import "ThrioApp.h"
#import "ThrioChannel.h"

NS_ASSUME_NONNULL_BEGIN

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation ThrioFlutterPage

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

- (void)onNotifyWithName:(NSString *)name
                  params:(nullable NSDictionary *)params {
  if (self.pageUrl.length < 1) {
    return;
  }

  NSDictionary *arguments = @{
    @"name": name,
    @"url": self.pageUrl,
    @"index": self.pageIndex,
    @"params": params ?: @{}
  };
  [[ThrioApp.shared channel] sendEvent:@"__onNotify__" arguments:arguments];
}

- (void)viewDidLayoutSubviews {
  
  [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    
  [self sendPageLifecycleEvent:ThrioPageLifecycleWillAppear];

  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  
  [ThrioApp.shared attachFlutterPage:self];
  
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
  if (self.pageUrl.length < 1) {
    return;
  }
  NSDictionary *arguments = @{
    @"url": self.pageUrl,
    @"index": self.pageIndex,
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
    case ThrioPageLifecycleBackground:
      return @"PageLifecycle.background";
    case ThrioPageLifecycleForeground:
      return @"PageLifecycle.foreground";
    default:
      return nil;
  }
}

@end
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_END
