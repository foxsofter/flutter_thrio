//
//  UINavigationController+FlutterEngine.m
//  thrio
//
//  Created by fox softer on 2020/2/22.
//

#import <objc/runtime.h>

#import "UINavigationController+FlutterEngine.h"
#import "NavigatorReceiveChannel.h"
#import "ThrioLogger.h"
#import "ThrioException.h"
#import "ThrioNavigator+Internal.h"
#import "NSObject+ThrioSwizzling.h"

@interface UINavigationController ()

@property (nonatomic, strong, readwrite, nullable) FlutterEngine *thrio_engine;

@property (nonatomic, strong, readwrite, nullable) ThrioChannel *thrio_channel;

@property (nonatomic, strong) NavigatorReceiveChannel *thrio_receiveChannel;

@property (nonatomic, strong) ThrioFlutterViewController *thrio_emptyViewController;

@end

@implementation UINavigationController (FlutterEngine)

- (FlutterEngine * _Nullable)thrio_engine {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setThrio_engine:(FlutterEngine * _Nullable)engine {
  objc_setAssociatedObject(self,
                           @selector(thrio_engine),
                           engine,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ThrioChannel * _Nullable)thrio_channel {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setThrio_channel:(ThrioChannel * _Nullable)channel {
  objc_setAssociatedObject(self,
                           @selector(thrio_channel),
                           channel,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NavigatorReceiveChannel * _Nullable)thrio_receiveChannel {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setThrio_receiveChannel:(NavigatorReceiveChannel * _Nullable)channel {
  objc_setAssociatedObject(self,
                           @selector(thrio_receiveChannel),
                           channel,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ThrioFlutterViewController *)thrio_emptyViewController {
  return objc_getAssociatedObject(self, _cmd);
}

- (void)setThrio_emptyViewController:(ThrioFlutterViewController *)viewController {
  objc_setAssociatedObject(self,
                           @selector(thrio_emptyViewController),
                           viewController,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ThrioFlutterViewController *)thrio_flutterViewController {
  if (self.thrio_engine.viewController != self.thrio_emptyViewController) {
    return (ThrioFlutterViewController*)self.thrio_engine.viewController;
  }
  return nil;
}

- (void)thrio_startup {
  if (!self.thrio_engine) {
    self.thrio_channel = [ThrioChannel channelWithName:@"__thrio_app__"];
    self.thrio_receiveChannel = [[NavigatorReceiveChannel alloc] initWithChannel:self.thrio_channel];
    [self thrio_startupFlutter];
    [self thrio_registerPlugin];
  }
}

- (void)thrio_shutdown {
  if (self.thrio_engine) {
    self.thrio_channel = nil;
    self.thrio_receiveChannel = nil;
    [self.thrio_engine destroyContext];
    self.thrio_engine = nil;
  }
}

- (void)thrio_attachFlutterViewController:(ThrioFlutterViewController *)viewController {
  ThrioLogV(@"enter attach flutter view controller");
  if (self.thrio_engine.viewController != viewController) {
    ThrioLogV(@"attach new flutter view controller");
    [(ThrioFlutterViewController*)self.thrio_engine.viewController surfaceUpdated:NO];
    self.thrio_engine.viewController = viewController;
  }
}

- (void)thrio_detachFlutterViewController:(ThrioFlutterViewController *)viewController {
  ThrioLogV(@"enter detach flutter view controller");
  if (self.thrio_engine.viewController == viewController) {
    ThrioLogV(@"detach flutter view controller");
    self.thrio_engine.viewController = self.thrio_emptyViewController;
  }
}

- (void)thrio_startupFlutter {
  NSString *enginName = [NSString stringWithFormat:@"io.flutter.%lu", (unsigned long)self.hash];
  self.thrio_engine = [[FlutterEngine alloc] initWithName:enginName project:nil];
  BOOL result = [self.thrio_engine run];
  if (!result) {
    @throw [ThrioException exceptionWithName:@"FlutterFailedException"
                                      reason:@"run flutter engine failed!"
                                    userInfo:nil];
  }
}

- (void)thrio_registerPlugin {
  Class clazz = NSClassFromString(@"GeneratedPluginRegistrant");
  if (clazz) {
    if ([clazz respondsToSelector:NSSelectorFromString(@"registerWithRegistry:")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      [clazz performSelector:NSSelectorFromString(@"registerWithRegistry:")
                  withObject:self.thrio_engine];
#pragma clang diagnostic pop
    }
  }
}

#pragma mark - method swizzling

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self instanceSwizzle:NSSelectorFromString(@"dealloc")
              newSelector:@selector(thrio_dealloc)];
  });
}

- (void)thrio_dealloc {
  [self thrio_shutdown];
  [self thrio_dealloc];
}

@end
