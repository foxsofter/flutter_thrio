// The MIT License (MIT)
//
// Copyright (c) 2022 foxsofter
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

#import "ThrioFlutterEngine.h"
#import <objc/message.h>

@interface ThrioFlutterEngine ()

- (id)performSelector:(SEL)aSelector withObject:(id)obj1 withObject:(id)obj2 withObject:(id)obj3 withObject:(id)obj4;

@end

@implementation ThrioFlutterEngine


- (instancetype)initWithName:(NSString *)labelPrefix
      allowHeadlessExecution:(BOOL)allowHeadlessExecution {
    return [super initWithName:labelPrefix project:nil allowHeadlessExecution:allowHeadlessExecution];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (ThrioFlutterEngine*)forkWithEntrypoint:(NSString *)entrypoint
                         withInitialRoute:(nullable NSString *)initialRoute
                            withArguments:(nullable NSArray *)arguments {
    SEL sel = @selector(spawnWithEntrypoint:libraryURI:initialRoute:entrypointArgs:);
    return [self performSelector:sel withObject:entrypoint withObject:nil withObject:initialRoute withObject:arguments];
}
#pragma clang diagnostic pop

- (id)performSelector:(SEL)aSelector withObject:(id)obj1 withObject:(id)obj2 withObject:(id)obj3 withObject:(id)obj4 {
    if (!aSelector) [self doesNotRecognizeSelector:aSelector];
    return ((id(*)(id, SEL, id, id, id, id))objc_msgSend)(self, aSelector, obj1, obj2, obj3, obj4);
}

@end
