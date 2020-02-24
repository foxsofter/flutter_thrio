//
//  UIViewController+PopDisabled.m
//  thrio
//
//  Created by foxsofter on 2020/2/22.
//

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
    [self.navigationController.thrio_channel invokeMethod:@"__onSetPopDisabled__"
                                                arguments:arguments];
  }
}

@end
