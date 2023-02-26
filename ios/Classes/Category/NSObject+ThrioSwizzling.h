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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ThrioSwizzling)

/// 交换当前类方法的实现
///
/// `oldSelector`  原类方法的实现
/// `newSelector`  新类方法的实现
///
+ (void)classSwizzle:(SEL)oldSelector newSelector:(SEL)newSelector;

/// 交换当前类的实例方法的实现
///
/// `oldSelector`  原实例方法的实现
/// `newSelector`  新实例方法的实现
///
+ (void)instanceSwizzle:(SEL)oldSelector newSelector:(SEL)newSelector;

/// 交换`targetCls`类方法的实现
///
/// `oldSelector`  原实例方法的实现
/// `newSelector`  新实例方法的实现
///
+ (void)classSwizzle:(SEL)oldSelector
           targetCls:(Class)targetCls
         newSelector:(SEL)newSelector;

/// 交换`targetCls`类的实例方法的实现
///
/// `oldSelector`  原实例方法的实现
/// `newSelector`  新实例方法的实现
///
+ (void)instanceSwizzle:(SEL)oldSelector
              targetCls:(Class)targetCls
            newSelector:(SEL)newSelector;

@end

NS_ASSUME_NONNULL_END
