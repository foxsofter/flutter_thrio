//
//  ThrioRouterChannel.h
//  Pods-Runner
//
//  Created by foxsofter on 2019/12/9.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

#import "ThrioRouterTypes.h"

NS_ASSUME_NONNULL_BEGIN


@interface ThrioRouterChannel : NSObject<FlutterStreamHandler>

+ (instancetype)channelWithName;

+ (instancetype)channelWithName:(NSString *)channelName;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)invokeMethod:(NSString*)method arguments:(id _Nullable)arguments;

- (void)invokeMethod:(NSString*)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback;

- (ThrioVoidCallback)registryMethodCall:(NSString *)method
                                handler:(ThrioMethodHandler)handler;

- (void)sendEvent:(NSString *)name arguments:(id _Nullable)arguments;

- (ThrioVoidCallback)registryEventHandling:(NSString *)name
                                   handler:(ThrioEventHandler)handler;

@end

NS_ASSUME_NONNULL_END
