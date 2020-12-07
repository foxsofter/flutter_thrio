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

- (void)onModuleRegister {
    [self registerModule:[Module1 new]];
    [self registerModule:[Module2 new]];
}

- (void)onModuleInit {
}

- (void)onJsonSerializerRegister {
    [self registerJsonSerializer:^NSDictionary *_Nullable (id params) {
        return [params toJson];
    } forClass:THRPeople.class];
}

- (void)onJsonDeserializerRegister {
    [self registerJsonDeserializer:^id _Nullable(NSDictionary *params) {
        return [THRPeople fromJson:params];
    } forClass:THRPeople.class];
}

@end

NS_ASSUME_NONNULL_END
