//
//  ThrioModulePageBuilder.h
//  Pods-Runner
//
//  Created by Wei ZhongDan on 2020/10/2.
//

#import <Foundation/Foundation.h>
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ThrioModulePageBuilder <NSObject>

/// Register native view controller builder for url.
///
/// Do not override this method.
///
- (ThrioVoidCallback)registerPageBuilder:(NavigatorPageBuilder)builder
                                  forUrl:(NSString *)url;

/// Sets the `NavigatorFlutterViewController` builder.
///
/// Need to be register when extending the `NavigatorFlutterViewController` class.
///
/// Do not override this method.
///
- (void)setFlutterPageBuilder:(NavigatorFlutterPageBuilder)builder;

@end

@interface ThrioModulePageBuilder : NSObject<ThrioModulePageBuilder>

@end

NS_ASSUME_NONNULL_END
