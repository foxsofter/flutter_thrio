// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

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

+ (void)classSwizzle:(SEL)oldSelector
           targetCls:(Class)targetCls
         newSelector:(SEL)newSelector {
    Class cls = object_getClass((id)self);
    Method oldMethod = class_getClassMethod(targetCls, oldSelector);
    Method newMethod = class_getClassMethod(cls, newSelector);
    
    if (class_addMethod(targetCls, oldSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(targetCls, newSelector, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
    } else {
        method_exchangeImplementations(oldMethod, newMethod);
    }
}

+ (void)instanceSwizzle:(SEL)oldSelector
              targetCls:(Class)targetCls
            newSelector:(SEL)newSelector {
    Class cls = [self class];
    Method oldMethod = class_getInstanceMethod(targetCls, oldSelector);
    Method newMethod = class_getInstanceMethod(cls, newSelector);
    
    if (class_addMethod(targetCls, oldSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(targetCls, newSelector, method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
    } else {
        method_exchangeImplementations(oldMethod, newMethod);
    }
}


@end
