//
//  ThrioRegistrySet.h
//  thrio
//
//  Created by foxsofter on 2019/12/10.
//

#import <Foundation/Foundation.h>

#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioRegistrySet<__covariant ObjectType> : NSObject<NSFastEnumeration>

+ (instancetype)set;

- (ThrioVoidCallback)registry:(ObjectType)value;

- (ThrioVoidCallback)registryAll:(NSSet<ObjectType> *)values;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
