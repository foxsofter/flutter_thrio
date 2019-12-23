//
//  ThrioFlutterApp.h
//  thrio
//
//  Created by foxsofter on 2019/12/19.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

#import "ThrioModule.h"
#import "ThrioFlutterPage.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioFlutterApp : ThrioModule

+ (instancetype)shared;

@property (nonatomic, strong, readonly) FlutterEngine *engine;

@property (nonatomic, strong, readonly) ThrioFlutterPage *page;

// Sets the `FlutterViewController` for flutter engine.
//
- (void)attach:(ThrioFlutterPage *)page;

- (void)detach;

// Set flutter app to `AppLifecycleState.inactive`
//
- (void)inactive;

// Set flutter app to `AppLifecycleState.paused`
//
- (void)pause;

// Set flutter app to `AppLifecycleState.resumed`
//
- (void)resume;

@end

NS_ASSUME_NONNULL_END
