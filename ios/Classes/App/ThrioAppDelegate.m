//
//  ThrioAppDelegate.m
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioAppDelegate.h"
#import "ThrioFlutterApp.h"
#import "ThrioModule.h"

@implementation ThrioAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  [ThrioModule register:ThrioFlutterApp.shared];
  
  return [super application:application willFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  [ThrioModule init];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


@end
