//
//  ThrioFlutterViewController.m
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioFlutterViewController.h"
#import "UIViewController+ThrioPageRoute.h"
#import "UINavigationController+ThrioNavigator.h"
#import "ThrioApp.h"
#import "ThrioChannel.h"
#import "ThrioLogger.h"

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

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  ThrioLogV(@"flutter page did appear: url=%@,index=%@",
            self.thrio_lastRoute.settings.url,
            self.thrio_lastRoute.settings.index);
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [[UIApplication sharedApplication].delegate.window endEditing:YES];
}

- (void)dealloc {
  [ThrioApp.shared detachFlutterViewController];
}

// override
- (void)installSplashScreenViewIfNecessary {
  //Do nothing.
}

// override
- (BOOL)loadDefaultSplashScreenView {
  return NO;
}

@end
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_END
