//
//  ThrioRouterLogger.m
//  thrio_router
//
//  Created by foxsofter on 2019/12/11.
//

#import "ThrioRouterLogger.h"
#import "ThrioRouterChannel.h"

@implementation ThrioRouterLogger

static NSString *const kLoggerChannelName = @"__thrio_router_logger__";

+ (void)v:(id)message {
  [self v:message error:nil];
}

+ (void)v:(id)message error:(NSError *)error {
  [[ThrioRouterChannel channelWithName:kLoggerChannelName]
                          invokeMethod:@"v"
                             arguments:@{
                               @"message": message,
                               @"description": error.localizedDescription
                             }];
}

+ (void)d:(id)message {
  [self d:message error:nil];
}

+ (void)d:(id)message error:(NSError *)error {
  [[ThrioRouterChannel channelWithName:kLoggerChannelName]
                          invokeMethod:@"d"
                             arguments:@{
                               @"message": message,
                               @"description": error.localizedDescription
                             }];
}

+ (void)i:(id)message {
  [self i:message error:nil];
}

+ (void)i:(id)message error:(NSError *)error {
  [[ThrioRouterChannel channelWithName:kLoggerChannelName]
                          invokeMethod:@"i"
                             arguments:@{
                               @"message": message,
                               @"description": error.localizedDescription
                             }];
}

+ (void)w:(id)message {
  [self w:message error:nil];
}

+ (void)w:(id)message error:(NSError *)error {
  [[ThrioRouterChannel channelWithName:kLoggerChannelName]
                          invokeMethod:@"w"
                             arguments:@{
                               @"message": message,
                               @"description": error.localizedDescription
                             }];
}

+ (void)e:(id)message {
  [self e:message error:nil];
}

+ (void)e:(id)message error:(NSError *)error {
  [[ThrioRouterChannel channelWithName:kLoggerChannelName]
                          invokeMethod:@"e"
                             arguments:@{
                               @"message": message,
                               @"description": error.localizedDescription,
                               @"stackTrace": [NSThread callStackSymbols]
                             }];
}

@end
