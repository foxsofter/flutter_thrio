//
//  ThrioModulePageObserver.h
//  Pods-Runner
//
//  Created by Wei ZhongDan on 2020/10/2.
//

#import <Foundation/Foundation.h>
#import "ThrioTypes.h"
#import "NavigatorPageObserverProtocol.h"
#import "ThrioModule.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ThrioModulePageObserver <NSObject>

/// Register observers for the life cycle of native pages and Dart pages.
///
/// Do not override this method.
///
- (ThrioVoidCallback)registerPageObserver:(id<NavigatorPageObserverProtocol>)pageObserver;

@end

@interface ThrioModule (PageObserver) <ThrioModulePageObserver>

@end

NS_ASSUME_NONNULL_END
