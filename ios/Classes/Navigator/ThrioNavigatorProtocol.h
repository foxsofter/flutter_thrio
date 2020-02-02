//
//  ThrioNavigatorProtocol.h
//  Pods-Runner
//
//  Created by foxsofter on 2019/12/27.
//

#import <Foundation/Foundation.h>
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ThrioNavigatorProtocol <NSObject>

- (void)pushUrl:(NSString *)url
         params:(NSDictionary *)params
       animated:(BOOL)animated
         result:(ThrioBoolCallback)result;

- (BOOL)canPushUrl:(NSString *)url
            params:(NSDictionary * _Nullable)params;

- (void)notifyUrl:(NSString *)url
            index:(NSNumber *)index
             name:(NSString *)name
           params:(NSDictionary *)params
           result:(ThrioBoolCallback)result;

- (BOOL)canNotifyUrl:(NSString *)url
               index:(NSNumber * _Nullable)index;

- (void)popAnimated:(BOOL)animated
             result:(ThrioBoolCallback)result;

- (BOOL)canPop;

- (void)popToUrl:(NSString *)url
           index:(NSNumber *)index
        animated:(BOOL)animated
          result:(ThrioBoolCallback)result;

- (BOOL)canPopToUrl:(NSString *)url
              index:(NSNumber * _Nullable)index;

- (void)removeUrl:(NSString *)url
            index:(NSNumber *)index
         animated:(BOOL)animated
           result:(ThrioBoolCallback)result;

- (BOOL)canRemoveUrl:(NSString *)url
               index:(NSNumber * _Nullable)index;

- (NSNumber *)lastIndex;

- (NSNumber *)getLastIndexByUrl:(NSString *)url;

- (NSArray *)getAllIndexByUrl:(NSString *)url;

- (void)setPopDisabledUrl:(NSString *)url
                    index:(NSNumber *)index
                 disabled:(BOOL)disabled;

@end

NS_ASSUME_NONNULL_END
