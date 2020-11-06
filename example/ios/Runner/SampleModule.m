//
//  SampleModule.m
//  Runner
//
//  Created by foxsofter on 2020/2/23.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "SampleModule.h"
#import "Module1.h"
#import "Module2.h"
#import "CustomFlutterViewController.h"

@implementation SampleModule

- (void)onModuleRegister {
    [self registerModule:[Module1 new]];
    [self registerModule:[Module2 new]];
}

- (void)onModuleInit {
    [self setFlutterPageBuilder:^(NSString *entrypoint) {
        return [[CustomFlutterViewController alloc] initWithEntrypoint:entrypoint];
    }];
}

@end
