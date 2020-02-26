#import "AppDelegate.h"
@import thrio;

#import "MainModule.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//  [ThrioNavigator setMultiEngineEnabled:NO];
  MainModule *main = [MainModule new];
  [main registerModule:main];
  [main initModule];
  
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


@end
