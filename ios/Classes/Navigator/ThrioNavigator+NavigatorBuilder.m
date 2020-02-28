//
//  ThrioNavigator+NavigatorBuilder.m
//  thrio
//
//  Created by foxsofter on 2020/2/22.
//

#import <objc/runtime.h>
#import "ThrioNavigator+NavigatorBuilder.h"

@implementation ThrioNavigator (NavigatorBuilder)

+ (ThrioVoidCallback)registerNativeViewControllerBuilder:(ThrioNativeViewControllerBuilder)builder
                                                  forUrl:(NSString *)url {
  ThrioRegistryMap *builders = self.nativeViewControllerBuilders;
  if (!builders) {
    builders = [ThrioRegistryMap map];
    self.nativeViewControllerBuilders = builders;
  }
  return [builders registry:url value:builder];
}

+ (ThrioVoidCallback)registerFlutterViewControllerBuilder:(ThrioFlutterViewControllerBuilder)builder {
  self.flutterViewControllerBuilder = builder;
  return ^ {
    self.flutterViewControllerBuilder = nil;
  };
}

+ (ThrioFlutterViewControllerBuilder _Nullable)flutterViewControllerBuilder {
  return objc_getAssociatedObject(self, _cmd);
}

+ (void)setFlutterViewControllerBuilder:(ThrioFlutterViewControllerBuilder _Nullable)builder {
  objc_setAssociatedObject(self,
                           @selector(flutterViewControllerBuilder),
                           builder,
                           OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (ThrioRegistryMap *)nativeViewControllerBuilders {
  return objc_getAssociatedObject(self, _cmd);
}

+ (void)setNativeViewControllerBuilders:(ThrioRegistryMap *)builders {
  objc_setAssociatedObject(self,
                           @selector(nativeViewControllerBuilders),
                           builders,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSMutableSet *)flutterPageRegisteredUrls {
  NSMutableSet *urls = (NSMutableSet*)objc_getAssociatedObject(self, _cmd);
  if (!urls) {
    urls = [NSMutableSet set];
    objc_setAssociatedObject(self,
                             _cmd,
                             urls,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return urls;
}

@end
