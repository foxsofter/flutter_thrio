//
//  ThrioFlutterPage.m
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioFlutterPage.h"
#import "UIViewController+ThrioPage.h"
#import "ThrioFlutterApp.h"
#import "../Channel/ThrioChannel.h"

@interface ThrioFlutterPage ()


@end

@implementation ThrioFlutterPage

- (instancetype)init {
  self = [super initWithEngine:ThrioFlutterApp.shared.engine nibName:nil bundle:nil];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = UIColor.whiteColor;
}

- (void)onNotifyWithName:(nonnull NSString *)name
                  params:(nullable NSDictionary *)params {
  NSDictionary *arguments = @{
    @"url": self.pageUrl,
    @"index": self.pageIndex,
    @"params": params ?: @{}
  };
  [[ThrioChannel channelWithName] sendEvent:name arguments:arguments];
}

- (void)viewDidLayoutSubviews {
  
  [super viewDidLayoutSubviews];
  
  [ThrioFlutterApp.shared resume];
}


- (void)viewWillAppear:(BOOL)animated {
    
  [self sendPageLifecycleEvent:ThrioPageLifecycleWillAppear];

  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  
  [ThrioFlutterApp.shared attach:self];
  
  [self sendPageLifecycleEvent:ThrioPageLifecycleAppeared];

  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  
  [[UIApplication sharedApplication].delegate.window endEditing:YES];

  [self sendPageLifecycleEvent:ThrioPageLifecycleWillDisappeared];

  [super viewWillDisappear:animated];
}

// override
- (void)installSplashScreenViewIfNecessary {
  //Do nothing.
}

// override
- (BOOL)loadDefaultSplashScreenView {
  return NO;
}

#pragma mark - private methods

- (void)sendPageLifecycleEvent:(ThrioPageLifecycle)lifecycle {
  NSDictionary *arguments = @{
    @"url": self.pageUrl,
    @"index": self.pageIndex,
    @"params": self.pageParams
  };
  NSString *eventName = pageLifecycleToString(lifecycle);
  [[ThrioChannel channelWithName] sendEvent:eventName arguments:arguments];
}

@end


