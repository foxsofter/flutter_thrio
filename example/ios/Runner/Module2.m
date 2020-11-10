//
//  Module2.m
//  Runner
//
//  Created by foxsofter on 2020/2/23.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "Module2.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@implementation Module2

- (void)onPageRegister {
    [self
     registerPageBuilder:^UIViewController *_Nullable (
         NSDictionary<NSString *, id> *_params) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        return [sb
                instantiateViewControllerWithIdentifier:@"ThrioViewController2"];
    }
                  forUrl:@"/biz1/native2"];

    [self registerRouteObserver:self];
}

- (void)didPop:(NavigatorRouteSettings *)routeSettings {
}

- (void)didPopTo:(NavigatorRouteSettings *)routeSettings {
}

- (void)didPush:(NavigatorRouteSettings *)routeSettings {
}

- (void)didRemove:(NavigatorRouteSettings *)routeSettings {
}

@end

NS_ASSUME_NONNULL_END
