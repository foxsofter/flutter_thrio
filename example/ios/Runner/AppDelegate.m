#import "AppDelegate.h"
#import <thrio/Thrio.h>

#import "MainModule.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  //  [ThrioNavigator setMultiEngineEnabled:NO];
  [ThrioModule init:[MainModule new]];
  
  // Override point for customization after application launch.
  return YES;
}

@end
