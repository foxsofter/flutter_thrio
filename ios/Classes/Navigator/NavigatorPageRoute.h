//
//  NavigatorPageRoute.h
//  thrio
//
//  Created by foxsofter on 2020/1/19.
//

#import <Foundation/Foundation.h>

#import "NavigatorRouteSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorPageRoute : NSObject

+ (instancetype)routeWithSettings:(NavigatorRouteSettings *)settings;

- (instancetype)initWithSettings:(NavigatorRouteSettings *)settings;

- (void)addNotify:(NSString *)name params:(NSDictionary *)params;

- (NSDictionary * _Nullable)removeNotify:(NSString *)name;

@property (nonatomic, strong, nullable) NavigatorPageRoute *prev;

@property (nonatomic, strong, nullable) NavigatorPageRoute *next;

@property (nonatomic, strong, readonly) NavigatorRouteSettings *settings;

@property (nonatomic, copy, readonly) NSDictionary *notifications;

@property (nonatomic, assign) BOOL popDisabled;

@end

NS_ASSUME_NONNULL_END
