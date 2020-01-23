//
//  MainModule.m
//  Runner
//
//  Created by Wei ZhongDan on 2019/12/28.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

@import thrio;
#import "MainModule.h"

@implementation MainModule

- (void)onModuleRegister {
  [ThrioModule register:ThrioApp.shared];
}

- (void)onPageRegister {
  [ThrioApp.shared registerNativeViewControllerBuilder:^UIViewController * _Nullable(NSDictionary<NSString *,id> * _Nonnull params) {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"ThrioViewController"];
  } forUrl:@"native1"];
}

@end
