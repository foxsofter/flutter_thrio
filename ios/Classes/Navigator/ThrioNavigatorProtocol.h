//
//  ThrioNavigatorProtocol.h
//  Pods-Runner
//
//  Created by Wei ZhongDan on 2019/12/27.
//

#import <Foundation/Foundation.h>
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ThrioNavigatorProtocol <NSObject>

- (void)push:(NSString *)url
      params:(NSDictionary *)params
    animated:(BOOL)animated
      result:(ThrioBoolCallback)result;

- (BOOL)canPush:(NSString *)url
         params:(NSDictionary * _Nullable)params;

- (void)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index
        params:(NSDictionary *)params
        result:(ThrioBoolCallback)result;

- (BOOL)canNotify:(NSString *)url
            index:(NSNumber * _Nullable)index;

- (void)popTo:(NSString *)url
        index:(NSNumber *)index
     animated:(BOOL)animated
       result:(ThrioBoolCallback)result;

- (BOOL)canPop:(NSString *)url
         index:(NSNumber * _Nullable)index;

- (void)pop:(NSString *)url
      index:(NSNumber *)index
   animated:(BOOL)animated
     result:(ThrioBoolCallback)result;

- (BOOL)canPopTo:(NSString *)url
           index:(NSNumber * _Nullable)index;

@end

NS_ASSUME_NONNULL_END
