//
//  Module2.m
//  Runner
//
//  Created by foxsofter on 2020/2/23.
//  Copyright © 2020 foxsofter. All rights reserved.
//

#import "Module2.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@implementation Module2

- (void)onPageBuilderRegister:(ThrioModuleContext *)moduleContext {
    [self registerPageBuilder:^UIViewController *_Nullable (id params) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        return [sb instantiateViewControllerWithIdentifier:@"ThrioViewController2"];
    } forUrl:@"/biz2/native2"];
}

- (void)onRouteObserverRegister:(ThrioModuleContext *)moduleContext {
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
