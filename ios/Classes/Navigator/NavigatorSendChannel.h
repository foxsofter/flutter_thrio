//
//  NavigatorSendChannel.h
//  thrio
//
//  Created by fox softer on 2020/3/16.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "ThrioChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorSendChannel : NSObject

- (instancetype)initWithChannel:(ThrioChannel *)channel;

- (void)onPush:(id _Nullable)arguments result:(FlutterResult _Nullable)callback;

- (void)onNotify:(id _Nullable)arguments result:(FlutterResult _Nullable)callback;

- (void)onPop:(id _Nullable)arguments result:(FlutterResult _Nullable)callback;

- (void)onPopTo:(id _Nullable)arguments result:(FlutterResult _Nullable)callback;

- (void)onRemove:(id _Nullable)arguments result:(FlutterResult _Nullable)callback;

@end

NS_ASSUME_NONNULL_END
