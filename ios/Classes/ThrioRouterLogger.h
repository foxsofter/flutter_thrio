//
//  ThrioRouterLogger.h
//  thrio_router
//
//  Created by foxsofter on 2019/12/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef ThrioLogV
#define ThrioLogV(msg) [ThrioRouterLogger v:(msg)]
#endif

#ifndef ThrioLogD
#define ThrioLogD(msg) [ThrioRouterLogger d:(msg)]
#endif

#ifndef ThrioLogI
#define ThrioLogI(msg) [ThrioRouterLogger i:(msg)]
#endif

#ifndef ThrioLogW
#define ThrioLogW(msg) [ThrioRouterLogger w:(msg)]
#endif

#ifndef ThrioLogE
#define ThrioLogE(msg) [ThrioRouterLogger e:(msg)]
#endif

@interface ThrioRouterLogger : NSObject

+ (void)v:(id)message;

+ (void)v:(id)message error:(nullable NSError *)error;

+ (void)d:(id)message;

+ (void)d:(id)message error:(nullable NSError *)error;

+ (void)i:(id)message;

+ (void)i:(id)message error:(nullable NSError *)error;

+ (void)w:(id)message;

+ (void)w:(id)message error:(nullable NSError *)error;

+ (void)e:(id)message;

+ (void)e:(id)message error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
