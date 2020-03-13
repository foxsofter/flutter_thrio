//
//  NavigatorRouteObserverProtocol.h
//  thrio
//
//  Created by Wei ZhongDan on 2020/3/13.
//

#import <Foundation/Foundation.h>

#import "NavigatorRouteSettings.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NavigatorPageObserverProtocol <NSObject>

- (void)onCreate:(NavigatorRouteSettings *)settings;

- (void)willAppear:(NavigatorRouteSettings *)settings;

- (void)didAppear:(NavigatorRouteSettings *)settings;

- (void)willDisappear:(NavigatorRouteSettings *)settings;

- (void)didDisappear:(NavigatorRouteSettings *)settings;

@end

NS_ASSUME_NONNULL_END
