//
//  ThrioRouterPlugin.m
//  thrio_router
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioRouterPlugin.h"
#import "ThrioRouterChannel.h"

@implementation ThrioRouterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"thrio_router"
            binaryMessenger:[registrar messenger]];
  ThrioRouterPlugin* instance = [[ThrioRouterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
