//
//  ThrioModulePageBuilder.m
//  Pods-Runner
//
//  Created by Wei ZhongDan on 2020/10/2.
//

#import "ThrioModulePageBuilder.h"
#import "ThrioNavigator+PageBuilders.h"

@implementation ThrioModulePageBuilder

- (void)onPageRegister {
    
}

- (ThrioVoidCallback)registerPageBuilder:(NavigatorPageBuilder)builder
                                  forUrl:(NSString *)url {
    return [ThrioNavigator.pageBuilders registry:url value:builder];
}

- (void)setFlutterPageBuilder:(NavigatorFlutterPageBuilder)builder {
    ThrioNavigator.flutterPageBuilder = builder;
}

@end
