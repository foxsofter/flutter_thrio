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

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "ThrioModule+JsonDeserializers.h"
#import "ThrioModuleTypes.h"

@implementation ThrioModule (JsonDeserializers)

+ (ThrioRegistryMap *)jsonDeserializers {
    id deserializers = objc_getAssociatedObject(self, _cmd);
    if (!deserializers) {
        deserializers = [ThrioRegistryMap map];
        objc_setAssociatedObject(self, _cmd, deserializers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return deserializers;
}

+ (id _Nullable)deserializeParams:(id _Nullable)params {
    if (!params || ![params isKindOfClass:NSDictionary.class]) {
        return params;
    }

    NSString *type = params[@"__thrio_TParams__"];
    if (!type) {
        return params;
    }
    // 来自 FlutterEngine
    ThrioRegistryMap *jsonDeserializers = [ThrioModule jsonDeserializers];
    ThrioJsonDeserializer deserializer = jsonDeserializers[type];
    if (!deserializer) {
        for (NSString *key in jsonDeserializers) {
            if ([key hasSuffix:type]) {
                deserializer = jsonDeserializers[key];
                break;
            }
        }
    }
    if (!deserializer) {
        return params;
    }
    return deserializer(params);
}

@end
