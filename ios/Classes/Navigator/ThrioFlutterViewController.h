//
//  ThrioFlutterViewController.h
//  thrio
//
//  Created by foxsofter on 2019/12/11.
//

#import <Flutter/Flutter.h>
#import "ThrioNotifyProtocol.h"
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

// A container class for Flutter pages.
//
@interface ThrioFlutterViewController : FlutterViewController<UINavigationControllerDelegate>

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil
                         bundle:(NSBundle * _Nullable)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithEngine:(FlutterEngine*)engine
                       nibName:(NSString* _Nullable)nibName
                        bundle:(NSBundle* _Nullable)nibBundle NS_UNAVAILABLE;
- (instancetype)initWithProject:(FlutterDartProject* _Nullable)project
                        nibName:(NSString* _Nullable)nibName
                         bundle:(NSBundle* _Nullable)nibBundle NS_UNAVAILABLE;

- (void)surfaceUpdated:(BOOL)appeared;

@end

NS_ASSUME_NONNULL_END
