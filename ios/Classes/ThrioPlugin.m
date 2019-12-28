//
//  ThrioPlugin.m
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioPlugin.h"
#import "ThrioChannel.h"

@implementation ThrioPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [ThrioChannel.channel setupMethodChannel:registrar.messenger];
  [ThrioChannel.channel setupEventChannel:registrar.messenger];
}

@end
