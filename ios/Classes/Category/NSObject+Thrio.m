//
//  NSObject+Thrio.m
//  thrio
//
//  Created by aadan on 2021/2/13.
//

#import <Flutter/Flutter.h>
#import "NSObject+Thrio.h"

@implementation NSObject (Thrio)

- (BOOL)canTransToFlutter {
    return [self isKindOfClass:NSNumber.class] ||
           [self isKindOfClass:NSString.class] ||
           [self isKindOfClass:FlutterStandardTypedData.class] ||
           [self isKindOfClass:NSArray.class] ||
           [self isKindOfClass:NSDictionary.class];
}

@end
