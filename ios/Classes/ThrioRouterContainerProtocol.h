//
//  ThrioRouterContainerProtocol.h
//  thrio_router
//
//  Created by foxsofter on 2019/12/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ThrioRouterContainerProtocol <NSObject>

@property (nonatomic, copy, readonly) NSString *thrio_url;

@property (nonatomic, strong, readonly) NSNumber *thrio_index;

@property (nonatomic, copy, readonly) NSDictionary *thrio_params;

@property (nonatomic, strong) NSMutableDictionary *thrio_notifications;

- (void)thrio_setUrl:(NSString *)url
              params:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
