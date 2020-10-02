//
//  Module1.m
//  Runner
//
//  Created by foxsofter on 2020/2/23.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Module1.h"

@implementation Module1

- (void)onPageRegister {
    [self registerPageBuilder:^UIViewController *_Nullable (NSDictionary<NSString *, id> *_Nonnull params) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        return [sb instantiateViewControllerWithIdentifier:@"ThrioViewController"];
    } forUrl:@"native1"];
    
    [self registerPageObserver:self];
}

- (void)onCreate:(NavigatorRouteSettings *)routeSettings {
}

- (void)willAppear:(NavigatorRouteSettings *)routeSettings {
}

- (void)didAppear:(NavigatorRouteSettings *)routeSettings {
}

- (void)willDisappear:(NavigatorRouteSettings *)routeSettings {
}

- (void)didDisappear:(NavigatorRouteSettings *)routeSettings {
}

@end
