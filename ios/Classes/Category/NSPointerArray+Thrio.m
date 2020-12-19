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

#import "NSPointerArray+Thrio.h"

@implementation NSPointerArray (Thrio)

- (BOOL)empty {
    [self compact];
    return self.count == 0;
}

- (id _Nullable)first {
    [self compact];
    if (self.count > 0) {
        return (__bridge id)[self pointerAtIndex:0];
    }
    return nil;
}

- (id _Nullable)last {
    [self compact];
    if (self.count > 0) {
        return (__bridge id)[self pointerAtIndex:self.count - 1];
    }
    return nil;
}

- (void)addObject:(id)object {
    [self compact];
    [self addPointer:(__bridge void *)object];
}

- (BOOL)containsObject:(id)object {
    [self compact];
    NSInteger index = -1;
    for (NSInteger i = 0; i < self.count; i++) {
        NSObject *obj = (__bridge id)[self pointerAtIndex:i];
        if (obj == object) {
            index = i;
            break;
        }
    }
    return index != -1;
}

- (void)removeFirstObject:(id)object {
    [self compact];
    if (self.count < 1) {
        return;
    }
    NSInteger index = -1;
    for (NSInteger i = 0; i < self.count; i++) {
        NSObject *obj = (__bridge id)[self pointerAtIndex:i];
        if (obj == object) {
            index = i;
            break;
        }
    }
    if (index != -1) {
        [self removePointerAtIndex:index];
    }
}

- (void)removeLastObject:(id)object {
    [self compact];
    if (self.count < 1) {
        return;
    }
    NSInteger index = -1;
    for (NSInteger i = self.count - 1; i >= 0; i--) {
        id obj = (__bridge id)[self pointerAtIndex:i];
        if (obj == object) {
            index = i;
            break;
        }
    }
    if (index != -1) {
        [self removePointerAtIndex:index];
    }
}

- (void)addAndRemoveObject:(id)object {
    [self compact];
    for (NSInteger i = 0; i < self.count; i++) {
        id obj = (__bridge id)[self pointerAtIndex:i];
        if (obj == object) {
            [self removePointerAtIndex:i];
        }
    }
    [self addPointer:(__bridge void *)object];
}

@end
