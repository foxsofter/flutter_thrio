//
//  NSObject+ThrioSwizzling.m
//  thrio
//
//  Created by foxsofter on 2020/1/6.
//

#import <objc/runtime.h>

#import "NSObject+ThrioSwizzling.h"

@implementation NSObject (ThrioSwizzling)

+ (void)classSwizzle:(SEL)oldSelector newSelector:(SEL)newSelector {
  Class cls = object_getClass((id)self);
  Method oldMethod = class_getClassMethod(cls, oldSelector);
  Method newMethod = class_getClassMethod(cls, newSelector);

  if (class_addMethod(cls, oldSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
    class_replaceMethod(cls, newSelector, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
  } else {
    method_exchangeImplementations(oldMethod, newMethod);
  }
}

+ (void)instanceSwizzle:(SEL)oldSelector newSelector:(SEL)newSelector {
  Class cls = [self class];
  Method oldMethod = class_getInstanceMethod(cls, oldSelector);
  Method newMethod = class_getInstanceMethod(cls, newSelector);

  if (class_addMethod(cls, oldSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
    class_replaceMethod(cls, newSelector, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
  } else {
    method_exchangeImplementations(oldMethod, newMethod);
  }
}


@end
