#import "AppDelegate.h"
#import <thrio/Thrio.h>
#import <Flutter/Flutter.h>

#import "MainModule.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)              application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ThrioModule init:[MainModule new]];
//    [ThrioModule init:[MainModule new] multiEngineEnabled:YES];

    // Flutter页面作为第一页
    UINavigationController *nvc = [[NavigatorNavigationController alloc] initWithUrl:@"/biz1/flutter3" params:nil];
    self.window.rootViewController = nvc;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
