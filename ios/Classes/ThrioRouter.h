//
//  ThrioRouter.h
//  thrio_router
//
//  Created by Wei ZhongDan on 2019/12/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThrioRouter : NSObject

+ (instancetype)router;

#pragma - notify methods

- (BOOL)notify:(NSString *)name
           url:(NSString *)url;

- (BOOL)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index;

- (BOOL)notify:(NSString *)name
           url:(NSString *)url
        params:(NSDictionary *)params;

- (BOOL)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index
        params:(NSDictionary *)params;

#pragma - push methods

- (BOOL)push:(NSString *)url;

- (BOOL)push:(NSString *)url
    animated:(BOOL)animated;

- (BOOL)push:(NSString *)url
      params:(NSDictionary *)params;

- (BOOL)push:(NSString *)url
      params:(NSDictionary *)params
    animated:(BOOL)animated;

#pragma - pop methods

- (void)pop:(NSString *)url;

- (void)pop:(NSString *)url
      index:(NSNumber *)index;

- (void)pop:(NSString *)url
   animated:(BOOL)animated;

- (void)pop:(NSString *)url
      index:(NSNumber *)index
   animated:(BOOL)animated;

#pragma - popTo methods

- (void)popTo:(NSString *)url;

- (void)popTo:(NSString *)url
        index:(NSNumber *)index;

- (void)popTo:(NSString *)url
     animated:(BOOL)animated;

- (void)popTo:(NSString *)url
        index:(NSNumber *)index
     animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
