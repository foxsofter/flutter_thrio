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

@implementation SampleModule

- (void)onModuleRegister {
  [self registerModule:[Module1 new]];
  [self registerModule:[Module2 new]];
}

@end
