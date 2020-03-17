//
//  Module2.m
//  Runner
//
//  Created by foxsofter on 2020/2/23.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Module2.h"

@implementation Module2

- (void)onPageRegister {
  [self registerNativePageBuilder:^UIViewController * _Nullable(NSDictionary<NSString *,id> * _Nonnull params) {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"ThrioViewController2"];
  } forUrl:@"native2"];
}

@end
