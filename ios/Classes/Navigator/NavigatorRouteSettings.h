//
//  NavigatorRouteSettings.h
//  Pods-Runner
//
//  Created by foxsofter on 2020/1/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorRouteSettings : NSObject

+ (instancetype)settingsWithUrl:(NSString *)url
                          index:(NSNumber *)index
                         nested:(BOOL)nested
                         params:(NSDictionary *)params;

- (instancetype)initWithUrl:(NSString *)url
                      index:(NSNumber *)index
                     nested:(BOOL)nested
                     params:(NSDictionary *)params;

- (NSDictionary *)toArguments;

- (NSDictionary *)toArgumentsWithoutParams;

@property (nonatomic, copy, readonly) NSString *url;

@property (nonatomic, strong, readonly) NSNumber *index;

@property (nonatomic, assign, readonly) BOOL nested;

@property (nonatomic, copy, readonly) NSDictionary *params;

@end

NS_ASSUME_NONNULL_END
