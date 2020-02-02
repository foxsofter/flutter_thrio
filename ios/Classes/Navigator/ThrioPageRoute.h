//
//  ThrioPageRoute.h
//  thrio
//
//  Created by foxsofter on 2020/1/19.
//

#import <Foundation/Foundation.h>

#import "ThrioRouteSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioPageRoute : NSObject

+ (instancetype)routeWithSettings:(ThrioRouteSettings *)settings;

- (instancetype)initWithSettings:(ThrioRouteSettings *)settings;

- (void)addNotify:(NSString *)name params:(NSDictionary *)params;

- (NSDictionary * _Nullable)removeNotify:(NSString *)name;

@property (nonatomic, strong, nullable) ThrioPageRoute *prev;

@property (nonatomic, strong, nullable) ThrioPageRoute *next;

@property (nonatomic, strong, readonly) ThrioRouteSettings *settings;

@property (nonatomic, copy, readonly) NSDictionary *notifications;

@end

NS_ASSUME_NONNULL_END
