// The MIT License (MIT)
//
// Copyright (c) 2020 foxsofter
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
#import "ThrioModuleTypes.h"
#import "ThrioModule+JsonSerializers.h"

@implementation ThrioModule (JsonSerializers)

+ (ThrioRegistryMap *)jsonSerializers {
    id serializers = objc_getAssociatedObject(self, _cmd);
    if (!serializers) {
        serializers = [ThrioRegistryMap map];
        objc_setAssociatedObject(self, _cmd, serializers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return serializers;
}

+ (id _Nullable)serializeParams:(id _Nullable)params {
    if (!params) {
        return nil;
    }

    // 已经序列化过了
    if ([params isKindOfClass:NSDictionary.class] &&
        [[params allKeys] containsObject:@"__thrio_TParams__"]) {
        return params;
    }
    NSString *type = NSStringFromClass([params class]);
    ThrioJsonSerializer serializer = [ThrioModule jsonSerializers][type];
    if (!serializer) {
        return params;
    }
    NSMutableDictionary *serializeParams = [@{ @"__thrio_TParams__": type } mutableCopy];
    [serializeParams addEntriesFromDictionary:serializer(params)];
    return serializeParams;
}

@end
