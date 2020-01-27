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

- (void)viewWillDisappear:(BOOL)animated {
  
  [[UIApplication sharedApplication].delegate.window endEditing:YES];

  [super viewWillDisappear:animated];
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
