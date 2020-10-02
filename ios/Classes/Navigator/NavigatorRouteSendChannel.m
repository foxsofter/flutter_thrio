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

#import "NavigatorRouteSendChannel.h"

@interface NavigatorRouteSendChannel ()

@property (nonatomic, strong) ThrioChannel *channel;

@end

@implementation NavigatorRouteSendChannel

- (instancetype)initWithChannel:(ThrioChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
    }
    return self;
}

- (void)onPush:(id _Nullable)arguments result:(ThrioBoolCallback _Nullable)result {
    [self _on:@"onPush" arguments:arguments result:^(id _Nullable value) {
        if (result) {
            if ([value isKindOfClass:NSNumber.class]) {
                result([value boolValue]);
            } else {
                result(NO);
            }
        }
    }];
}

- (void)onNotify:(id _Nullable)arguments result:(ThrioBoolCallback _Nullable)result {
    [_channel sendEvent:@"__onNotify__" arguments:arguments];
    result(YES);
}

- (void)onPop:(id _Nullable)arguments result:(ThrioBoolCallback _Nullable)result {
    [self _on:@"onPop" arguments:arguments result:^(id _Nullable value) {
        if (result) {
            if ([value isKindOfClass:NSNumber.class]) {
                result([value boolValue]);
            } else {
                result(NO);
            }
        }
    }];
}

- (void)onPopTo:(id _Nullable)arguments result:(ThrioBoolCallback _Nullable)result {
    [self _on:@"onPopTo" arguments:arguments result:^(id _Nullable value) {
        if (result) {
            if ([value isKindOfClass:NSNumber.class]) {
                result([value boolValue]);
            } else {
                result(NO);
            }
        }
    }];
}

- (void)onRemove:(id _Nullable)arguments result:(ThrioBoolCallback _Nullable)result {
    [self _on:@"onRemove" arguments:arguments result:^(id _Nullable value) {
        if (result) {
            if ([value isKindOfClass:NSNumber.class]) {
                result([value boolValue]);
            } else {
                result(NO);
            }
        }
    }];
}

- (void)  _on:(NSString *)method
    arguments:(id _Nullable)arguments
       result:(ThrioIdCallback _Nullable)result {
    NSString *channelMethod = [NSString stringWithFormat:@"__%@__", method];
    [_channel invokeMethod:channelMethod
                 arguments:arguments
                    result:result];
}

@end
