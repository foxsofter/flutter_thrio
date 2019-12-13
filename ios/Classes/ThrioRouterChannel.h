//
//  ThrioRouterChannel.h
//  Pods-Runner
//
//  Created by Wei ZhongDan on 2019/12/9.
//

#import <Foundation/Foundation.h>

#import "ThrioRouterTypes.h"

NS_ASSUME_NONNULL_BEGIN


@interface ThrioRouterChannel : NSObject

+ (instancetype)channelWithName:(NSString *)channelName
                        binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger ;

- (void)invokeMethod:(NSString*)method arguments:(id _Nullable)arguments;

- (void)invokeMethod:(NSString*)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback;

- (ThrioVoidCallback)registryMethodHandler:(NSString *)method
                                   handler:(ThrioMethodHandler)handler;

@end

NS_ASSUME_NONNULL_END
