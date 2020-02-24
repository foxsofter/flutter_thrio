//
//  ThrioNavigator+Internal.m
//  thrio
//
//  Created by foxsofter on 2020/2/23.
//

#import "ThrioNavigator+Internal.h"
#import "UIApplication+Thrio.h"

@implementation ThrioNavigator (Internal)

+ (UINavigationController * _Nullable)navigationController {
  return [[UIApplication sharedApplication] topmostNavigationController];
}

@end
