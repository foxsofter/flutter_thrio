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

- (bool)notify:(NSString *)name
           url:(NSString *)url
         index:(NSNumber *)index
        params:(NSDictionary *)params {
  
}

@end

NS_ASSUME_NONNULL_END
