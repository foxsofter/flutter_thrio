//
//  ThrioRouterContainer.h
//  thrio_router
//
//  Created by Wei ZhongDan on 2019/12/11.
//

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThrioRouterContainer : FlutterViewController

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil
                         bundle:(NSBundle * _Nullable)nibBundleOrNil NS_UNAVAILABLE;


@property (nonatomic, copy, readonly) NSString *url;

@property (nonatomic, strong, readonly) NSNumber *index;

@property (nonatomic, copy, readonly) NSDictionary *params;

- (void)setUrl:(NSString *)url params:(NSDictionary * _Nullable)params;

@end

NS_ASSUME_NONNULL_END
