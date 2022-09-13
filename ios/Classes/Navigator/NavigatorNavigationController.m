// The MIT License (MIT)
//
// Copyright (c) 2020 foxsofter
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
#import "NavigatorFlutterEngineFactory.h"
#import "NavigatorFlutterViewController.h"
#import "NavigatorNavigationController.h"
#import "ThrioModule+PageBuilders.h"
#import "FlutterThrioTypes.h"
#import "UIViewController+Internal.h"
#import "UIViewController+Navigator.h"
#import "UIViewController+ThrioInjection.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorNavigationController ()

@property (nonatomic) NSString *initialUrl;
@property (nonatomic, nullable) id initialParams;

@end

@implementation NavigatorNavigationController

- (instancetype)initWithUrl:(NSString *)url params:(id _Nullable)params {
    _initialUrl = url;
    _initialParams = params;
    UIViewController *viewController;
    NavigatorPageBuilder builder = [ThrioModule pageBuilders][url];
    if (builder) {
        viewController = builder(params);
        if (viewController.thrio_hidesNavigationBar_ == nil) {
            viewController.thrio_hidesNavigationBar_ = @NO;
        }
    }
    // 不是原生页面
    if (!viewController) {
        NSString *entrypoint = kNavigatorDefaultEntrypoint;
        if (NavigatorFlutterEngineFactory.shared.multiEngineEnabled) {
            entrypoint = [url componentsSeparatedByString:@"/"][1];
        }
        NavigatorFlutterEngine *engine =
        [NavigatorFlutterEngineFactory.shared startupWithEntrypoint:entrypoint readyBlock:nil];
        NavigatorFlutterPageBuilder flutterBuilder = [ThrioModule flutterPageBuilder];
        if (flutterBuilder) {
            viewController = flutterBuilder(engine);
        } else {
            viewController = [[NavigatorFlutterViewController alloc] initWithEngine:engine];
        }
        // 调用一次让 engine 状态变成被使用
        NSUInteger pageId = [(NavigatorFlutterViewController *)viewController pageId];
        [NavigatorFlutterEngineFactory.shared getEngineByPageId:pageId withEntrypoint:entrypoint];
        __weak typeof(self) weakSelf = self;
        [(NavigatorFlutterViewController *)viewController setFlutterViewDidRenderCallback:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.topViewController thrio_pushUrl:strongSelf.initialUrl
                                                  index:@1
                                                 params:strongSelf.initialParams
                                               animated:NO
                                         fromEntrypoint:entrypoint
                                             fromPageId:pageId
                                                 result:nil
                                           poppedResult:nil];
        }];
    } else {
        __weak typeof(self) weakSelf = self;
        [viewController registerInjectionBlock:^(UIViewController *vc, BOOL animated) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!vc.thrio_lastRoute) {
                [vc  thrio_pushUrl:strongSelf.initialUrl
                             index:@1
                            params:strongSelf.initialParams
                          animated:NO
                    fromEntrypoint:nil
                        fromPageId:kNavigatorRoutePageIdNone
                            result:nil
                      poppedResult:nil];
            }
        } afterLifecycle:ThrioViewControllerLifecycleViewDidAppear];
    }
    return [super initWithRootViewController:viewController];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}

@end

NS_ASSUME_NONNULL_END
