//
//  SampleModule.h
//  Runner
//
//  Created by foxsofter on 2020/2/23.
//  Copyright © 2020 foxsofter. All rights reserved.
//

#import <flutter_thrio/FlutterThrio.h>

NS_ASSUME_NONNULL_BEGIN

@interface SampleModule : ThrioModule<ThrioModuleJsonSerializer,
                                      ThrioModuleJsonDeserializer>

@end

NS_ASSUME_NONNULL_END
