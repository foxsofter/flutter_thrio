//
//  Module1.m
//  Runner
//
//  Created by foxsofter on 2020/2/23.
//  Copyright © 2020 foxsofter. All rights reserved.
//

#import "Module1.h"
#import <UIKit/UIKit.h>

@implementation Module1

- (void)onPageBuilderRegister:(ThrioModuleContext *)moduleContext {
    [self registerPageBuilder:^UIViewController *_Nullable (id params) {
        ThrioLogI(@"/biz1/native1 pushed params: %@", params);
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        return [sb instantiateViewControllerWithIdentifier:@"ThrioViewController"];
    } forUrl:@"/biz1/native1"];
}

- (void)onPageObserverRegister:(ThrioModuleContext *)moduleContext {
    [self registerPageObserver:self];
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
