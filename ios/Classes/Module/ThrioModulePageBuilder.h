//
//  ThrioModulePageBuilder.h
//  Pods-Runner
//
//  Created by foxsofter on 2020/10/2.
//

#import <Foundation/Foundation.h>
#import "ThrioTypes.h"
#import "ThrioModule.h"

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

@class ThrioModule;

@interface ThrioModule (PageBuilder) <ThrioModulePageBuilder>

/// A function for register a `PageBuilder` .
///
- (void)onPageBuilderRegister:(ThrioModuleContext *)moduleContext;

@end

NS_ASSUME_NONNULL_END
