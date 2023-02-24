#import "AppDelegate.h"
#import <flutter_thrio/FlutterThrio.h>
#import <Flutter/Flutter.h>

#import "MainModule.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)              application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ThrioModule init:[MainModule new] preboot:NO];
    UINavigationController *nvc = [[NavigatorNavigationController alloc] initWithUrl:@"/biz/biz1/flutter1/home" params:nil];
    self.window.rootViewController = nvc;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end

