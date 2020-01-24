#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MainModule.h"
@import thrio;

int main(int argc, char* argv[]) {
  @autoreleasepool {
    [ThrioModule register:MainModule.new];
    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
