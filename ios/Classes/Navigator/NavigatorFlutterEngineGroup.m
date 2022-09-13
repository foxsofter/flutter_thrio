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

#import "NavigatorConsts.h"
#import "NavigatorLogger.h"
#import "NavigatorFlutterEngineGroup.h"

@interface NavigatorFlutterEngineGroup ()

@property (nonatomic, copy, readwrite) NSString *entrypoint;

@property (nonatomic, strong) NSMutableDictionary *engineMap;

@property (nonatomic, strong) NavigatorFlutterEngine *mainEngine;

@property (nonatomic, strong) NavigatorFlutterEngine *currentEngine;

@property (nonatomic, assign) BOOL isRunning;

@end

@implementation NavigatorFlutterEngineGroup

- (instancetype)initWithEntrypoint:(NSString *)entrypoint {
    self = [super init];
    if (self) {
        _entrypoint = entrypoint;
        _engineMap = [NSMutableDictionary dictionary];
        _isRunning = NO;
    }
    return self;
}

- (NSArray *)engines {
    return [_engineMap.allValues copy];
}

- (NavigatorFlutterEngine *)startupWithReadyBlock:(ThrioEngineReadyCallback _Nullable)block {
    if (_isRunning) { // 引擎正在启动过了
        return _currentEngine;
    }
    _isRunning = YES;
    // 主引擎存在，且还没有使用
    if (_mainEngine && _mainEngine.pageId == kNavigatorRoutePageIdNone) {
        if (block) {
            block(_mainEngine);
            _currentEngine = _mainEngine;
            _isRunning = NO;
        }
        return _currentEngine;
    }
    ThrioFlutterEngine *flutterEngine = [_mainEngine.flutterEngine fork:_entrypoint];
    if (!flutterEngine) {
        NSString *enginName = [NSString stringWithFormat:@"io.flutter.%lu", (unsigned long)self.hash];
        NavigatorVerbose(@"new flutter engine: %@", engineName);
        flutterEngine = [[ThrioFlutterEngine alloc] initWithName:enginName allowHeadlessExecution:YES];
    }
    _currentEngine = [[NavigatorFlutterEngine alloc] initWithEntrypoint:_entrypoint withEngine:flutterEngine];
    if (_mainEngine == nil) {
        _mainEngine = _currentEngine;
    }
    __weak typeof(self) weakself = self;
    [_currentEngine startupWithReadyBlock: ^(NavigatorFlutterEngine * engine) {
        __strong typeof(weakself) strongSelf = weakself;
        strongSelf.isRunning = NO;
        if (block) {
            block(engine);
        }
    }];
    return _currentEngine;
}

- (BOOL)isMainEngineByPageId:(NSUInteger)pageId {
    return _engineMap[@(pageId)] == _mainEngine;
}

- (NavigatorFlutterEngine *_Nullable)getEngineByPageId:(NSUInteger)pageId {
    NSNumber *key = @(pageId);
    NavigatorFlutterEngine *engine = _engineMap[key] ;
    if (engine) {
        return engine;
    }
    // 被获取后，放到 engines 中并清空
    if (_currentEngine) {
        _currentEngine.pageId = pageId;
        _engineMap[key] = _currentEngine;
        _currentEngine = nil;
    }
    return _engineMap[key];
}

- (void)destroyEngineByPageId:(NSUInteger)pageId {
    NSNumber *key = @(pageId);
    NavigatorFlutterEngine *engine = _engineMap[key];
    if (engine) {
        [_engineMap removeObjectForKey:key];
    }
    if (_mainEngine.pageId == pageId) {
        _mainEngine.pageId = kNavigatorRoutePageIdNone;
    } else {
        [engine destroyContext];
    }
}

@end
