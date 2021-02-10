//
//  ThrioModulePageBuilder.m
//  Pods-Runner
//
//  Created by foxsofter on 2020/10/2.
//

#import "ThrioModule.h"
#import "ThrioModulePageBuilder.h"
#import "ThrioModule+PageBuilders.h"

@implementation ThrioModule (PageBuilder)

- (ThrioVoidCallback)registerPageBuilder:(NavigatorPageBuilder)builder
                                  forUrl:(NSString *)url {
    return [ThrioModule.pageBuilders registry:url value:builder];
}

- (void)setFlutterPageBuilder:(NavigatorFlutterPageBuilder)builder {
    ThrioModule.flutterPageBuilder = builder;
}

- (void)onPageBuilderRegister:(ThrioModuleContext *)moduleContext {
}

@end
