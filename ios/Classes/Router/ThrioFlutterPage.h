//
//  ThrioFlutterPage.h
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import <Flutter/Flutter.h>
#import "ThrioNotifyProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioFlutterPage : FlutterViewController<ThrioNotifyProtocol>

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithEngine:(FlutterEngine*)engine
                       nibName:(nullable NSString*)nibName
                        bundle:(nullable NSBundle*)nibBundle NS_UNAVAILABLE;
- (instancetype)initWithProject:(nullable FlutterDartProject*)project
                        nibName:(nullable NSString*)nibName
                         bundle:(nullable NSBundle*)nibBundle NS_UNAVAILABLE;

- (void)surfaceUpdated:(BOOL)appeared;

@end

NS_ASSUME_NONNULL_END
