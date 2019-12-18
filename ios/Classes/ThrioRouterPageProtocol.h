//
//  ThrioRouterPageProtocol.h
//  thrio_router
//
//  Created by Wei ZhongDan on 2019/12/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ThrioRouterPageProtocol <NSObject>

- (NSNumber *)thrio_latestPageIndexOfUrl:(NSString *)url;

- (NSArray *)thrio_allPageIndexOfUrl:(NSString *)url;

- (BOOL)thrio_containsPageWithUrl:(NSString *)url;

- (BOOL)thrio_containsPageWithUrl:(NSString *)url
                            index:(NSNumber *)index;

- (BOOL)thrio_notifyPageWithName:(NSString *)name
                             url:(NSString *)url
                           index:(NSNumber *)index
                          params:(NSDictionary *)params;

- (BOOL)thrio_popPageWithUrl:(NSString *)url
                       index:(NSNumber *)index
                    animated:(BOOL)animated;

- (BOOL)thrio_popToPageWithUrl:(NSString *)url
                         index:(NSNumber *)index
                      animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
