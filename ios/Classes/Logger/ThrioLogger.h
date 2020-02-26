//
//  ThrioLogger.h
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef ThrioLogV
#ifdef DEBUG
#define ThrioLogV(fmt, ...) NSLog(@"native: [V] %@", [NSString stringWithFormat:fmt, ##__VA_ARGS__])
#else
#define ThrioLogV(msg)
#endif
#endif

#ifndef ThrioLogD
#ifdef DEBUG
#define ThrioLogD(fmt, ...) NSLog(@"native: [D] %@", [NSString stringWithFormat:fmt, ##__VA_ARGS__])
#else
#define ThrioLogD(msg)
#endif
#endif

#ifndef ThrioLogI
#ifdef DEBUG
#define ThrioLogI(fmt, ...) NSLog(@"native: [I] %@", [NSString stringWithFormat:fmt, ##__VA_ARGS__])
#else
#define ThrioLogI(msg)
#endif
#endif

#ifndef ThrioLogW
#ifdef DEBUG
#define ThrioLogW(fmt, ...) NSLog(@"native: [W] %@", [NSString stringWithFormat:fmt, ##__VA_ARGS__])
#else
#define ThrioLogW(msg)
#endif
#endif

#ifndef ThrioLogE
#ifdef DEBUG
#define ThrioLogE(fmt, ...) NSLog(@"native: [E] %@", [NSString stringWithFormat:fmt, ##__VA_ARGS__])
#else
#define ThrioLogE(msg)
#endif
#endif

NS_ASSUME_NONNULL_END
