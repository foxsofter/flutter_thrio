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


#import <objc/runtime.h>
#import "UINavigationController+FlutterEngine.h"
#import "UIViewController+PopDisabled.h"
#import "UIViewController+Navigator.h"
#import "ThrioFlutterViewController.h"
#import "ThrioNavigator.h"
#import "ThrioNavigator+Internal.h"

@implementation UIViewController (PopDisabled)

- (BOOL)thrio_popDisabled {
  return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setThrio_popDisabled:(BOOL)disabled {
  objc_setAssociatedObject(self,
                           @selector(thrio_popDisabled),
                           @(disabled),
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)thrio_setPopDisabled:(BOOL)disabled {
  [self thrio_setPopDisabledUrl:@"" index:@0 disabled:disabled];
}

- (void)thrio_setPopDisabledUrl:(NSString *)url
                          index:(NSNumber *)index
                       disabled:(BOOL)disabled {
  NavigatorPageRoute *route = [self thrio_getRouteByUrl:url index:index];
  route.popDisabled = disabled;
  
  NSMutableDictionary *arguments =
    [NSMutableDictionary dictionaryWithDictionary:[route.settings toArgumentsWithoutParams]];
  [arguments setObject:[NSNumber numberWithBool:disabled] forKey:@"disabled"];

  if (route != self.thrio_firstRoute && [self isKindOfClass:ThrioFlutterViewController.class]) {
    ThrioChannel *channel = [self.navigationController thrio_getChannelForEntrypoint:[(ThrioFlutterViewController*)self entrypoint]];
    [channel invokeMethod:@"__onSetPopDisabled__" arguments:arguments];
  }
}

@end
