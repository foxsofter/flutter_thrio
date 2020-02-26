//
//  ThrioFlutterEngine.h
//  thrio
//
//  Created by fox softer on 2020/2/25.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "ThrioTypes.h"
#import "ThrioFlutterViewController.h"
#import "ThrioChannel.h"
#import "NavigatorReceiveChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioFlutterEngine : NSObject

- (void)startupWithEntrypoint:(NSString *)entrypoint readyBlock:(ThrioVoidCallback)block;

- (void)shutdown;

@property (nonatomic, strong, readonly, nullable) FlutterEngine *engine;

@property (nonatomic, strong, readonly, nullable) ThrioChannel *channel;

@property (nonatomic, strong, readonly, nullable) NavigatorReceiveChannel *receiveChannel;

- (void)attachFlutterViewController:(ThrioFlutterViewController *)viewController;

- (void)detachFlutterViewController:(ThrioFlutterViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
