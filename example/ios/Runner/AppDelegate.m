#import "AppDelegate.h"
#import <thrio/thrio.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  
  [ThrioModule register:ThrioApp.shared];
  [ThrioModule init];
  
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
