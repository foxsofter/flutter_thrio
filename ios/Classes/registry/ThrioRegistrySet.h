//
//  ThrioRegistrySet.h
//  thrio
//
//  Created by foxsofter on 2019/12/10.
//

#import <Foundation/Foundation.h>

#import "../ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioRegistrySet : NSObject

+ (instancetype)set;

- (ThrioVoidCallback)registry:(id)value;

- (ThrioVoidCallback)registryAll:(NSSet *)values;

- (void)clear;

- (NSSet *)values;

@end

NS_ASSUME_NONNULL_END
