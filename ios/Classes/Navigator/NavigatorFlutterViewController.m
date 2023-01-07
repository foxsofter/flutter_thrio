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

#import "NavigatorConsts.h"
#import "NavigatorFlutterEngine.h"
#import "NavigatorFlutterEngineFactory.h"
#import "NavigatorFlutterViewController.h"
#import "NavigatorLogger.h"
#import "ThrioChannel.h"
#import "ThrioModule+PageObservers.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioNavigator.h"
#import "UINavigationController+Navigator.h"
#import "UIViewController+HidesNavigationBar.h"
#import "UIViewController+Internal.h"
#import "UIViewController+Navigator.h"
#import "UIApplication+Thrio.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorFlutterViewController ()

@property (nonatomic, weak, readwrite) NavigatorFlutterEngine *warpEngine;

@property (nonatomic, assign) NSUInteger pageId;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NavigatorFlutterViewController

- (instancetype)initWithEngine:(NavigatorFlutterEngine *)engine {
    _warpEngine = engine;
    _pageId = [self hash];
    engine.pageId = _pageId;
    self = [super initWithEngine:engine.flutterEngine nibName:nil bundle:nil];
    if (self) {
        self.thrio_hidesNavigationBar_ = @YES;
        self.hidesBottomBarWhenPushed = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewDidAppearFromBackgroud)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewDidDisappearFromForeground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        
    }
    return self;
}

- (NSString *)entrypoint {
    return _warpEngine.entrypoint;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![self isMovingToParentViewController]) {
        [ThrioModule.pageObservers willAppear:self.thrio_lastRoute.settings];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self isMovingToParentViewController]) {
        [ThrioModule.pageObservers didAppear:self.thrio_lastRoute.settings];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [ThrioModule.pageObservers willDisappear:self.thrio_lastRoute.settings];
    
    [[UIApplication sharedApplication].getKeyWindow endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([self.navigationController thrio_getAllRoutesByUrl:nil].count > 0) {
        [ThrioModule.pageObservers didDisappear:self.thrio_lastRoute.settings];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NavigatorVerbose(@"NavigatorFlutterViewController dealloc: %@", self);
    [NavigatorFlutterEngineFactory.shared destroyEngineByPageId:_pageId withEntrypoint:self.entrypoint];
}

- (void)viewDidAppearFromBackgroud {
    if (self == self.navigationController.viewControllers.lastObject) {
        [ThrioModule.pageObservers didAppear:self.thrio_lastRoute.settings];
    }
}

- (void)viewDidDisappearFromForeground {
    if (self == self.navigationController.viewControllers.lastObject) {
        [ThrioModule.pageObservers didDisappear:self.thrio_lastRoute.settings];
    }
}


@end
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_END
