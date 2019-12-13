//
//  ThrioRouterPredicate.h
//  thrio_router
//
//  Created by Wei ZhongDan on 2019/12/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Signature of predicate that can notify or not.
//
typedef bool (^ThrioNotifyPredicate)
             (NSString *url,
              NSNumber *index,
              NSDictionary *params);

// Signature of predicate that can pop or not.
//
typedef bool (^ThrioPopPredicate)
             (NSString *url,
              NSNumber *index,
              NSDictionary *params);

// Signature of predicate that can popTo or not.
//
typedef bool (^ThrioPopToPredicate)
             (NSString *url,
              NSNumber *index,
              NSDictionary *params);

// Signature of predicate that can push or not.
//
typedef bool (^ThrioPushPredicate)
             (NSString *url,
              NSNumber *index,
              NSDictionary *params);

// A class represents a predicate that can route or not.
//
@interface ThrioRouterPredicate : NSObject

+ (ThrioRouterPredicate *)predicate:(

@end

NS_ASSUME_NONNULL_END
