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

#import "NavigatorFlutterEngine.h"
#import "NavigatorFlutterEngineFactory.h"
#import "NavigatorFlutterViewController.h"
#import "NavigatorLogger.h"
#import "ThrioChannel.h"
#import "ThrioNavigator+Internal.h"
#import "ThrioModule+PageObservers.h"
#import "ThrioNavigator.h"
#import "UINavigationController+Navigator.h"
#import "UIViewController+HidesNavigationBar.h"
#import "UIViewController+Internal.h"
#import "UIViewController+Navigator.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorFlutterViewController ()

@property (nonatomic, copy, readwrite) NSString *entrypoint;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NavigatorFlutterViewController

- (instancetype)initWithEntrypoint:(NSString *)entrypoint {
    FlutterEngine *engine =
        [NavigatorFlutterEngineFactory.shared getEngineByEntrypoint:entrypoint];
    if (engine.viewController) {
        if ([engine.viewController
             isKindOfClass:NavigatorFlutterViewController.class]) {
            [NavigatorFlutterEngineFactory.shared
             popViewController:(NavigatorFlutterViewController *)
             engine.viewController];
        } else {
            engine.viewController = nil;
        }
    }
    self = [super initWithEngine:engine nibName:nil bundle:nil];
    if (self) {
        self.thrio_hidesNavigationBar_ = @YES;
        if (NavigatorFlutterEngineFactory.shared.multiEngineEnabled) {
            _entrypoint = entrypoint;
        } else {
            _entrypoint = @"main";
        }
    }
    self.hidesBottomBarWhenPushed = YES;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (![self isMovingToParentViewController]) {
        [ThrioModule.pageObservers willAppear:self.thrio_lastRoute.settings];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self isMovingToParentViewController]) {
        [NavigatorFlutterEngineFactory.shared pushViewController:self];
    } else {
        [ThrioModule.pageObservers didAppear:self.thrio_lastRoute.settings];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [ThrioModule.pageObservers willDisappear:self.thrio_lastRoute.settings];

    [[UIApplication sharedApplication].delegate.window endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if ([self.navigationController thrio_getAllRoutesByUrl:nil].count > 1) {
        [ThrioModule.pageObservers didDisappear:self.thrio_lastRoute.settings];
    }
}

- (void)dealloc {
    [NavigatorFlutterEngineFactory.shared popViewController:self];
    NavigatorVerbose(@"NavigatorFlutterViewController dealloc: %@", self);
    NSString *entrypoint = self.entrypoint;
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300)),
        dispatch_get_main_queue(), ^{
        NavigatorRouteSendChannel *channel =
            [NavigatorFlutterEngineFactory.shared
             getSendChannelByEntrypoint:entrypoint];
        if (!channel) {
            return;
        }
        NavigatorRouteSettings *settings =
            [[ThrioNavigator _getLastRouteByEntrypoint:entrypoint] settings];
        if (!settings) {
            settings = [NavigatorRouteSettings settingsWithUrl:@"/"
                                                         index:@0
                                                        nested:NO
                                                        params:nil];
        }
        NSMutableDictionary *arguments = [NSMutableDictionary
                                          dictionaryWithDictionary:[settings toArgumentsWithParams:nil]];
        [arguments setObject:@NO forKey:@"animated"];
        [channel popTo:arguments
                result:^(BOOL r) {
         }];
    });
}

@end
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_END
