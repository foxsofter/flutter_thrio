//
//  ThrioPlugin.m
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioPlugin.h"
#import "ThrioNavigator+Internal.h"
#import "UINavigationController+FlutterEngine.h"
#import "ThrioLogger.h"

@implementation ThrioPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [ThrioNavigator.navigationController.thrio_channel setupEventChannel:registrar.messenger];
  [ThrioNavigator.navigationController.thrio_channel setupMethodChannel:registrar.messenger];
  [[ThrioChannel channelWithName:kLoggerChannelName] setupMethodChannel:registrar.messenger];
}

@end
