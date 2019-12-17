//
//  ThrioRouterPredicate.h
//  thrio_router
//
//  Created by foxsofter on 2019/12/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Signature of predicate that can notify or not.
//
typedef BOOL (^ThrioNotifyPredicate)
             (NSString *url,
              NSNumber * _Nullable index,
              NSDictionary * _Nullable params);

// Signature of predicate that can pop or not.
//
typedef BOOL (^ThrioPopPredicate)
             (NSString *url,
              NSNumber * _Nullable index);

// Signature of predicate that can popTo or not.
//
typedef BOOL (^ThrioPopToPredicate)
             (NSString *url,
              NSNumber * _Nullable index);

// Signature of predicate that can push or not.
//
typedef BOOL (^ThrioPushPredicate)
             (NSString *url,
              NSDictionary * _Nullable params);

// A class represents a predicate that can route or not.
//
@interface ThrioRouterPredicate : NSObject

+ (instancetype)predicate;

- (instancetype)setCanNotify:(ThrioNotifyPredicate)canNotify;

- (instancetype)setCanPop:(ThrioPopPredicate)canPop;

- (instancetype)setCanPopTo:(ThrioPopToPredicate)canPopTo;

- (instancetype)setCanPush:(ThrioPushPredicate)canPush;

- (BOOL)canNotify:(NSString *)url
            index:(nullable NSNumber *)index
           params:(nullable NSDictionary *)params;

- (BOOL)canPop:(NSString *)url
         index:(nullable NSNumber *)index;

- (BOOL)canPopTo:(NSString *)url
           index:(nullable NSNumber *)index;

- (BOOL)canPush:(NSString *)url
         params:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
