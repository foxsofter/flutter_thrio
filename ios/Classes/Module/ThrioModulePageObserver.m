//
//  ThrioModulePageObserver.m
//  Pods-Runner
//
//  Created by foxsofter on 2020/10/2.
//

#import "ThrioModulePageObserver.h"
#import "ThrioNavigator+PageObservers.h"

@implementation ThrioModule (PageObserver)

- (ThrioVoidCallback)registerPageObserver:(id<NavigatorPageObserverProtocol>)pageObserver {
    return [ThrioNavigator.pageObservers registry:pageObserver];
}

@end
