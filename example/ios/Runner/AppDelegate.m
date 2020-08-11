#import "AppDelegate.h"
#import <thrio/Thrio.h>
#import <Flutter/Flutter.h>

#import "MainModule.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)              application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //  [ThrioNavigator setMultiEngineEnabled:NO];
    [ThrioModule init:[MainModule new]];

    return YES;
}

@end
