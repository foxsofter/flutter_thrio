//
//  ThrioPlugin.m
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioPlugin.h"

@implementation ThrioPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  if (!_registrar) {
    _registrar = registrar;
  }
}

static NSObject<FlutterPluginRegistrar>* _registrar;

+ (NSObject<FlutterPluginRegistrar>*)registrar {
  return _registrar;
}

@end
