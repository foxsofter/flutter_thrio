//
//  ThrioModulePageBuilder.m
//  Pods-Runner
//
//  Created by foxsofter on 2020/10/2.
//

#import "ThrioModule.h"
#import "ThrioModulePageBuilder.h"
#import "ThrioNavigator+PageBuilders.h"

@implementation ThrioModule (PageBuilder)

- (ThrioVoidCallback)registerPageBuilder:(NavigatorPageBuilder)builder
                                  forUrl:(NSString *)url {
    return [ThrioNavigator.pageBuilders registry:url value:builder];
}

- (void)setFlutterPageBuilder:(NavigatorFlutterPageBuilder)builder {
    ThrioNavigator.flutterPageBuilder = builder;
}

- (void)onPageBuilderRegister {
}

@end
