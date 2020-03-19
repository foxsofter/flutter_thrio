//
//  Module2.m
//  Runner
//
//  Created by foxsofter on 2020/2/23.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Module2.h"

NS_ASSUME_NONNULL_BEGIN

@implementation Module2

- (void)onPageRegister {
  [self registerPageBuilder:^UIViewController * _Nullable(NSDictionary<NSString *,id> * _params) {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"ThrioViewController2"];
  } forUrl:@"native2"];
  [self registerRouteObserver:self]();
}

- (void)didPop:(NavigatorRouteSettings *)routeSettings
 previousRoute:(NavigatorRouteSettings * _Nullable)previousRouteSettings {
}

- (void)didPopTo:(NavigatorRouteSettings *)routeSettings
   previousRoute:(NavigatorRouteSettings * _Nullable)previousRouteSettings {
}

- (void)didPush:(NavigatorRouteSettings *)routeSettings
  previousRoute:(NavigatorRouteSettings * _Nullable)previousRouteSettings {
}

- (void)didRemove:(NavigatorRouteSettings *)routeSettings
    previousRoute:(NavigatorRouteSettings * _Nullable)previousRouteSettings {
}

@end

NS_ASSUME_NONNULL_END
