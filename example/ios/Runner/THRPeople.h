//
//  THRPeople.h
//  Runner
//
//  Created by foxsofter on 2020/12/6.
//  Copyright © 2020 foxsofter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface THRPeople : NSObject

+ (_Nullable instancetype)fromJson:(NSDictionary *_Nullable)json;
- (instancetype)initWithJson:(NSDictionary *)json;

- (NSDictionary *_Nullable)toJson;

@property (nonatomic, copy)   NSString *name;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, copy)   NSString *sex;

@end

NS_ASSUME_NONNULL_END
