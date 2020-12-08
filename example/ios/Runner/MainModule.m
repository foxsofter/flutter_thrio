//
//  MainModule.m
//  Runner
//
//  Created by foxsofter on 2019/12/28.
//  Copyright © 2019 foxsofter. All rights reserved.
//

@import thrio;
#import "MainModule.h"
#import "SampleModule.h"
#import "CustomFlutterViewController.h"
#import <Runner-Swift.h>

@implementation MainModule

- (void)onModuleInit {
    [self setFlutterPageBuilder:^(NSString *entrypoint) {
        return [[CustomFlutterViewController alloc] initWithEntrypoint:entrypoint];
    }];
}

- (void)onModuleRegister {
    [self registerModule:[SampleModule new]];
    [self registerModule:[SwiftModule new]];
}

@end
