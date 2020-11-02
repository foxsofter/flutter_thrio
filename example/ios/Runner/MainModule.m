//
//  MainModule.m
//  Runner
//
//  Created by foxsofter on 2019/12/28.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

@import thrio;
#import "MainModule.h"
#import "SampleModule.h"
#import <Runner-Swift.h>

@implementation MainModule

- (void)onModuleInit {
}

- (void)onModuleRegister {
    [self registerModule:[SampleModule new]];
    [self registerModule:[SwiftModule new]];
}

@end
