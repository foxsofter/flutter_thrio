// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

#import "ThrioFlutterViewController.h"
#import "UIViewController+Navigator.h"
#import "UINavigationController+Navigator.h"
#import "ThrioFlutterEngineFactory.h"
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
  FlutterEngine *engine = [ThrioFlutterEngineFactory.shared getEngineByEntrypoint:entrypoint];
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
