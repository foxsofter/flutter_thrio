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

#import "NavigatorRouteSettings.h"
#import "UINavigationController+Navigator.h"
#import "UINavigationController+PopDisabled.h"
#import "UIViewController+Navigator.h"
#import "UIViewController+WillPopCallback.h"

@implementation UINavigationController (PopDisabled)

- (void)thrio_setPopDisabledUrl:(NSString *)url
                          index:(NSNumber *)index
                       disabled:(BOOL)disabled {
    UIViewController *viewController = [self getViewControllerByUrl:url index:index];
    NavigatorRouteSettings *settings = viewController.thrio_firstRoute.settings;
    if ([settings.url isEqualToString:url] && [settings.index isEqualToNumber:index]) {
        if (disabled) {
            // 设为具体值，拦截侧滑返回，但会继续传递给dart端，在dart端触发willPop
            viewController.thrio_willPopBlock = ^(ThrioBoolCallback _Nonnull result) {
                if (result) {
                    result(YES);
                }
            };
        } else {
            // 设为nil，不拦截侧滑返回
            viewController.thrio_willPopBlock = nil;
        }
    }
}

@end
