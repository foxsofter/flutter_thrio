//
//  ThrioNavigator+NavigatorBuilder.h
//  thrio
//
//  Created by foxsofter on 2020/2/22.
//

#import "ThrioNavigator.h"
#import "ThrioRegistryMap.h"
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioNavigator (NavigatorBuilder)


/// Register native view controller builder for url.
///
+ (ThrioVoidCallback)registerNativeViewControllerBuilder:(ThrioNativeViewControllerBuilder)builder
                                                  forUrl:(NSString *)url;

/// Sets the `ThrioFlutterViewController` builder.
///
/// Need to be register when extending the `ThrioFlutterViewController` class.
///
+ (ThrioVoidCallback)registerFlutterViewControllerBuilder:(ThrioFlutterViewControllerBuilder)builder;

+ (ThrioRegistryMap *)nativeViewControllerBuilders;

+ (ThrioFlutterViewControllerBuilder _Nullable)flutterViewControllerBuilder;

+ (NSMutableSet *)flutterPageRegisteredUrls;

@end

NS_ASSUME_NONNULL_END
