//
//  ThrioRegistrySetMap.h
//  thrio
//
//  Created by foxsofter on 2019/12/10.
//

#import <Foundation/Foundation.h>

#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioRegistrySetMap<__covariant KeyType, __covariant ObjectType> : NSObject<NSFastEnumeration>

+ (instancetype)map;

- (ThrioVoidCallback)registry:(KeyType<NSCopying>)key value:(ObjectType)value;

- (ThrioVoidCallback)registryAll:(NSDictionary<KeyType, ObjectType> *)values;

- (void)clear;

- (NSSet<ObjectType> *)objectForKeyedSubscript:(KeyType)key;

@end

NS_ASSUME_NONNULL_END
