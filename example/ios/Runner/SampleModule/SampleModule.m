//
//  SampleModule.m
//  Runner
//
//  Created by foxsofter on 2020/2/23.
//  Copyright © 2020 foxsofter. All rights reserved.
//

#import "SampleModule.h"
#import "Module1.h"
#import "Module2.h"
#import "THRPeople.h"

NS_ASSUME_NONNULL_BEGIN


@implementation SampleModule

- (void)onModuleRegister:(ThrioModuleContext *)moduleContext {
    [self registerModule:[Module1 new] withModuleContext:moduleContext];
    [self registerModule:[Module2 new] withModuleContext:moduleContext];
}

- (void)onModuleInit:(ThrioModuleContext *)moduleContext {
}

- (void)onJsonSerializerRegister:(ThrioModuleContext *)moduleContext {
    [self registerJsonSerializer:^NSDictionary *_Nullable (id params) {
        return [params toJson];
    } forClass:THRPeople.class];
}

- (void)onJsonDeserializerRegister:(ThrioModuleContext *)moduleContext {
    [self registerJsonDeserializer:^id _Nullable (NSDictionary *params) {
        return [THRPeople fromJson:params];
    } forClass:THRPeople.class];
}

@end

NS_ASSUME_NONNULL_END
