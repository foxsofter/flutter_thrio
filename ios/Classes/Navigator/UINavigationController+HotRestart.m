//
//  UINavigationController+HotRestart.m
//  thrio
//
//  Created by foxsofter on 2020/2/22.
//

#import "UINavigationController+HotRestart.h"
#import "UINavigationController+FlutterEngine.h"
#import "UIViewController+Navigator.h"
#import "ThrioLogger.h"
#import "ThrioFlutterViewController.h"
#import "NavigatorRouteSettings.h"
#import "ThrioNavigator.h"
#import "ThrioNavigator+Internal.h"

@implementation UINavigationController (HotRestart)

- (void)thrio_hotRestart:(ThrioBoolCallback)result {
  ThrioLogV(@"enter on hot restart");
  ThrioFlutterViewController *viewController;
  for (UIViewController *vc in self.viewControllers) {
    if ([vc isKindOfClass:ThrioFlutterViewController.class]) {
      viewController = (ThrioFlutterViewController*)vc;
      break;
    }
  }
  if (!viewController) {
    return;
  }
  if (viewController != self.topViewController) {
    [self popToViewController:viewController animated:YES];
  }
  
  viewController.thrio_firstRoute.next = nil;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    ThrioLogV(@"hot restart push");
    NavigatorRouteSettings *settings = viewController.thrio_firstRoute.settings;
    ThrioChannel *channel = [self thrio_getChannelForEntrypoint:viewController.entrypoint];
    [channel invokeMethod:@"__onPush__" arguments:[settings toArguments]];
  });
}

@end
