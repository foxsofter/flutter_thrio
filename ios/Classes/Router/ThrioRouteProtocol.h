//
//  ThrioRouteProtocol.h
//  Pods-Runner
//
//  Created by Wei ZhongDan on 2019/12/27.
//

#import <Foundation/Foundation.h>
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ThrioRouteProtocol <NSObject>

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index
        params:(NSDictionary *)params
        result:(ThrioBoolCallback)result;

- (BOOL)canNotify:(NSString *)url
            index:(nullable NSNumber *)index;

- (void)push:(NSString *)url
      params:(NSDictionary *)params
    animated:(BOOL)animated
      result:(ThrioBoolCallback)result;

- (BOOL)canPush:(NSString *)url
         params:(nullable NSDictionary *)params;

- (void)popTo:(NSString *)url
        index:(NSNumber *)index
     animated:(BOOL)animated
       result:(ThrioBoolCallback)result;

- (BOOL)canPop:(NSString *)url
         index:(nullable NSNumber *)index;

- (void)pop:(NSString *)url
      index:(NSNumber *)index
   animated:(BOOL)animated
     result:(ThrioBoolCallback)result;

- (BOOL)canPopTo:(NSString *)url
           index:(nullable NSNumber *)index;

@end

NS_ASSUME_NONNULL_END
