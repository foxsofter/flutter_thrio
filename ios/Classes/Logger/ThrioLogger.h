//
//  ThrioLogger.h
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kLoggerChannelName;

@interface ThrioLogger : NSObject

+ (void)v:(id)message;

+ (void)v:(id)message error:(NSError * _Nullable)error;

+ (void)d:(id)message;

+ (void)d:(id)message error:(NSError * _Nullable)error;

+ (void)i:(id)message;

+ (void)i:(id)message error:(NSError * _Nullable)error;

+ (void)w:(id)message;

+ (void)w:(id)message error:(NSError * _Nullable)error;

+ (void)e:(id)message;

+ (void)e:(id)message error:(NSError * _Nullable)error;

@end

#ifndef ThrioLogV
#ifdef DEBUG
#define ThrioLogV(fmt, ...) [ThrioLogger v:[NSString stringWithFormat:fmt, ##__VA_ARGS__]]
#else
#define ThrioLogV(msg)
#endif
#endif

#ifndef ThrioLogD
#ifdef DEBUG
#define ThrioLogD(fmt, ...) [ThrioLogger d:[NSString stringWithFormat:fmt, ##__VA_ARGS__]]
#else
#define ThrioLogD(msg)
#endif
#endif

#ifndef ThrioLogI
#ifdef DEBUG
#define ThrioLogI(fmt, ...) [ThrioLogger i:[NSString stringWithFormat:fmt, ##__VA_ARGS__]]
#else
#define ThrioLogI(msg)
#endif
#endif

#ifndef ThrioLogW
#ifdef DEBUG
#define ThrioLogW(fmt, ...) [ThrioLogger w:[NSString stringWithFormat:fmt, ##__VA_ARGS__]]
#else
#define ThrioLogW(msg)
#endif
#endif

#ifndef ThrioLogE
#ifdef DEBUG
#define ThrioLogE(fmt, ...) [ThrioLogger e:[NSString stringWithFormat:fmt, ##__VA_ARGS__]]
#else
#define ThrioLogE(msg)
#endif
#endif

NS_ASSUME_NONNULL_END
