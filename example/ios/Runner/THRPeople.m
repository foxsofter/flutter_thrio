//
//  THRPeople.m
//  Runner
//
//  Created by foxsofter on 2020/12/6.
//  Copyright © 2020 foxsofter. All rights reserved.
//

#import "THRPeople.h"

NS_ASSUME_NONNULL_BEGIN

@implementation THRPeople

+ (_Nullable instancetype)fromJson:(NSDictionary *_Nullable)json {
    return json ? [[THRPeople alloc] initWithJson:json] : nil;
}

- (instancetype)initWithJson:(NSDictionary *)json {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:json];
    }
    return self;
}

- (NSDictionary *_Nullable)toJson {
    return [self dictionaryWithValuesForKeys:THRPeople.properties.allValues];
}

+ (NSDictionary<NSString *, NSString *> *)properties {
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"name": @"name",
        @"age": @"age",
        @"sex": @"sex",
    };
}

- (void)setValue:(nullable id)value forKey:(NSString *)key {
    id resolved = THRPeople.properties[key];
    if (resolved) [super setValue:value forKey:resolved];
}

- (void)setNilValueForKey:(NSString *)key {
    id resolved = THRPeople.properties[key];
    if (resolved) [super setValue:@0 forKey:resolved];
}

@end

NS_ASSUME_NONNULL_END
