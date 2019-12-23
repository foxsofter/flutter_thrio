//
//  ThrioRouteProtocol.h
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ThrioPageProtocol <NSObject>

@property (nonatomic, copy) NSString *pageUrl;

@property (nonatomic, strong, readonly) NSNumber *pageIndex;

@property (nonatomic, copy) NSDictionary *pageParams;

@property (nonatomic, strong) NSDictionary *pageNotifications;

@end

NS_ASSUME_NONNULL_END
