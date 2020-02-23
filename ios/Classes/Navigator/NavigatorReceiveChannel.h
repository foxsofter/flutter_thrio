//
//  NavigatorReceiveChannel.h
//  thrio
//
//  Created by Wei ZhongDan on 2020/2/2.
//

#import <Foundation/Foundation.h>

#import "ThrioChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorReceiveChannel : NSObject

- (instancetype)initWithChannel:(ThrioChannel *)channel;

@end

NS_ASSUME_NONNULL_END
