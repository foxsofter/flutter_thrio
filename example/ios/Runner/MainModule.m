//
//  MainModule.m
//  Runner
//
//  Created by foxsofter on 2019/12/28.
//  Copyright © 2019 foxsofter. All rights reserved.
//

@import flutter_thrio;

#import "MainModule.h"
#import "SampleModule.h"
#import "CustomFlutterViewController.h"
#import "THRPeople.h"

@implementation MainModule

- (void)onModuleInit:(ThrioModuleContext *)moduleContext {
    [self setFlutterPageBuilder:^(NavigatorFlutterEngine *engine) {
        return [[CustomFlutterViewController alloc] initWithEngine:engine];
    }];
    
    THRPeople *people = [THRPeople fromJson:@{
        @"name": @"foxsofter test module",
        @"age": @100,
        @"sex": @"sss"
    }];
    [moduleContext set:people forKey:@"people_from_native"];
}

- (void)onModuleRegister:(ThrioModuleContext *)moduleContext {
    [self registerModule:[SampleModule new] withModuleContext:moduleContext];
}

@end
