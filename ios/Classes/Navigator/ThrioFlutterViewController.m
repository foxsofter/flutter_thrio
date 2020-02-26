//
//  ThrioFlutterViewController.m
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioFlutterViewController.h"
#import "UIViewController+Navigator.h"
#import "UINavigationController+Navigator.h"
#import "UINavigationController+FlutterEngine.h"
#import "ThrioNavigator.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioFlutterEngine.h"
#import "ThrioChannel.h"
#import "ThrioLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioFlutterViewController ()

@property (nonatomic, copy, readwrite) NSString *entrypoint;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation ThrioFlutterViewController

- (instancetype)initWithEntrypoint:(NSString *)entrypoint {
  FlutterEngine *engine = [ThrioNavigator.navigationController thrio_getEngineForEntrypoint:entrypoint];
  self = [super initWithEngine:engine nibName:nil bundle:nil];
  if (self) {
    self.thrio_hidesNavigationBar = @YES;
    if (ThrioNavigator.isMultiEngineEnabled) {
      _entrypoint = entrypoint;
    } else {
      _entrypoint = @"";
    }
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = UIColor.whiteColor;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[UIApplication sharedApplication].delegate.window endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

- (void)dealloc {
  ThrioLogV(@"ThrioFlutterViewController dealloc: %@", self);
}

// override
- (void)installSplashScreenViewIfNecessary {
  // Do nothing.
}

// override
- (BOOL)loadDefaultSplashScreenView {
  return NO;
}

@end
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_END
