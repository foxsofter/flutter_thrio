//
//  ThrioRouterNotifyProtocol.h
//  thrio_router
//
//  Created by WeiZhongDan on 2019/12/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// A protocol for implementing page notifications.
//
// The protocol must be implemented by a UIViewController.
//
@protocol ThrioRouterNotifyProtocol <NSObject>

// Called when the page has been fully transitioned onto the screen.
//
- (void)onNotifyWithName:(NSString *)name
                  params:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
