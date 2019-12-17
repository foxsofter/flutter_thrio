//
//  ThrioRegistryMap.h
//  thrio_router
//
//  Created by foxsofter on 2019/12/10.
//

#import <Foundation/Foundation.h>

#import "../ThrioRouterTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioRegistryMap : NSObject

+ (instancetype)map;

- (ThrioVoidCallback)registry:(NSString *)key value:(id)value;

- (ThrioVoidCallback)registryAll:(NSDictionary *)values;

- (void)clear;

- (id)objectForKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
