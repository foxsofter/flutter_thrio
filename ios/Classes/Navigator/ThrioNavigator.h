//
//  ThrioNavigator.h
//  ThrioNavigator
//
//  Created by foxsofter on 2019/12/11.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "ThrioNavigatorProtocol.h"
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioNavigator : NSObject<ThrioNavigatorProtocol>

+ (instancetype)shared;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - notify methods

- (void)notify:(NSString *)name
           url:(NSString *)url;

- (void)notify:(NSString *)name
           url:(NSString *)url
        result:(ThrioBoolCallback)result;

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index;

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index
        result:(ThrioBoolCallback)result;

- (void)notify:(NSString *)name
           url:(NSString *)url
        params:(NSDictionary *)params;

- (void)notify:(NSString *)name
           url:(NSString *)url
        params:(NSDictionary *)params
        result:(ThrioBoolCallback)result;

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index
        params:(NSDictionary *)params;

#pragma mark - push methods

- (void)push:(NSString *)url;

- (void)push:(NSString *)url
      result:(ThrioBoolCallback)result;

- (void)push:(NSString *)url
    animated:(BOOL)animated;

- (void)push:(NSString *)url
    animated:(BOOL)animated
      result:(ThrioBoolCallback)result;

- (void)push:(NSString *)url
      params:(NSDictionary *)params;

- (void)push:(NSString *)url
      params:(NSDictionary *)params
      result:(ThrioBoolCallback)result;

- (void)push:(NSString *)url
      params:(NSDictionary *)params
    animated:(BOOL)animated;

#pragma mark - pop methods

- (void)pop:(NSString *)url;

- (void)pop:(NSString *)url
     result:(ThrioBoolCallback)result;

- (void)pop:(NSString *)url
      index:(NSNumber *)index;

- (void)pop:(NSString *)url
      index:(NSNumber *)index
     result:(ThrioBoolCallback)result;

- (void)pop:(NSString *)url
   animated:(BOOL)animated;

- (void)pop:(NSString *)url
   animated:(BOOL)animated
     result:(ThrioBoolCallback)result;

- (void)pop:(NSString *)url
      index:(NSNumber *)index
   animated:(BOOL)animated;

#pragma mark - popTo methods

- (void)popTo:(NSString *)url;

- (void)popTo:(NSString *)url
       result:(ThrioBoolCallback)result;

- (void)popTo:(NSString *)url
        index:(NSNumber *)index;

- (void)popTo:(NSString *)url
        index:(NSNumber *)index
       result:(ThrioBoolCallback)result;

- (void)popTo:(NSString *)url
     animated:(BOOL)animated;

- (void)popTo:(NSString *)url
     animated:(BOOL)animated
       result:(ThrioBoolCallback)result;

- (void)popTo:(NSString *)url
        index:(NSNumber *)index
     animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
