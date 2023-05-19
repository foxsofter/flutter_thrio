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

#import "NavigatorFlutterEngineFactory.h"
#import "NavigatorFlutterViewController.h"
#import "NavigatorLogger.h"
#import "NavigatorRouteSettings.h"
#import "ThrioModule+JsonSerializers.h"
#import "ThrioNavigator.h"
#import "ThrioNavigator+Internal.h"
#import "UINavigationController+HotRestart.h"
#import "UIViewController+Navigator.h"

@implementation UINavigationController (HotRestart)

- (void)thrio_hotRestart:(ThrioBoolCallback)result {
    NavigatorVerbose(@"enter on hot restart");
    NavigatorFlutterViewController *viewController;
    for (UIViewController *vc in self.viewControllers) {
        if ([vc isKindOfClass:NavigatorFlutterViewController.class]) {
            viewController = (NavigatorFlutterViewController *)vc;
            break;
        }
    }
    if (!viewController) {
        return;
    }
    // 如果 NavigatorFlutterViewController 不在顶部则 popTo 让它出现在顶部
    if (viewController != self.topViewController) {
        [self popToViewController:viewController animated:YES];
    }
    
    viewController.thrio_firstRoute.next = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        NavigatorVerbose(@"hot restart push");
        NavigatorRouteSettings *settings = viewController.thrio_firstRoute.settings;
        id serializerParams = [ThrioModule serializeParams:settings.params];
        NavigatorRouteSendChannel *channel =
        [NavigatorFlutterEngineFactory.shared getSendChannelByEntrypoint:viewController.entrypoint];
        [channel push:[settings toArgumentsWithParams:serializerParams] result:nil];
    });
}

@end
