//
//  ThrioNavigationProtocol.h
//  thrio
//
//  Created by foxsofter on 2019/12/17.
//

#import <Foundation/Foundation.h>
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ThrioNavigationProtocol <NSObject>

- (BOOL)pushPageWithUrl:(NSString *)url
                 params:(NSDictionary *)params
               animated:(BOOL)animated;

- (BOOL)notifyPageWithName:(NSString *)name
                       url:(NSString *)url
                     index:(NSNumber *)index
                    params:(NSDictionary *)params;

- (BOOL)popPageWithUrl:(NSString *)url
                 index:(NSNumber *)index
              animated:(BOOL)animated;

- (BOOL)popToPageWithUrl:(NSString *)url
                   index:(NSNumber *)index
                animated:(BOOL)animated;

- (NSNumber *)latestPageIndexOfUrl:(NSString *)url;

- (NSArray *)allPageIndexOfUrl:(NSString *)url;

- (BOOL)containsPageWithUrl:(NSString *)url;

- (BOOL)containsPageWithUrl:(NSString *)url
                      index:(NSNumber *)index;

- (ThrioVoidCallback)registerNativePageBuilder:(ThrioNativePageBuilder)builder
                                        forUrl:(NSString *)url;

- (void)setFlutterPageBuilder:(ThrioFlutterPageBuilder)builder;

@end

NS_ASSUME_NONNULL_END
