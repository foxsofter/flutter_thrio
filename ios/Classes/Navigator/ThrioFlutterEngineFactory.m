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

#import "ThrioFlutterEngineFactory.h"
#import "ThrioFlutterEngine.h"
#import "ThrioNavigator.h"
#import "ThrioLogger.h"

@interface ThrioFlutterEngineFactory ()

@property (nonatomic, strong) NSMutableDictionary *flutterEngines;

@property (nonatomic, strong) NSMutableSet *flutterUrls;

@end

@implementation ThrioFlutterEngineFactory

+ (instancetype)shared {
  static ThrioFlutterEngineFactory *_instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _instance = [[self alloc] init];
  });
  return _instance;
}

- (NSMutableDictionary *)flutterEngines {
  if (!_flutterEngines) {
    _flutterEngines = [NSMutableDictionary dictionary];
  }
  return _flutterEngines;
}

- (NSMutableSet *)flutterUrls {
  if (!_flutterUrls) {
    _flutterUrls = [NSMutableSet set];
  }
  return _flutterUrls;
}

- (void)startupWithEntrypoint:(NSString *)entrypoint readyBlock:(ThrioVoidCallback)block {
  if (!ThrioNavigator.isMultiEngineEnabled) {
    entrypoint = @"";
  }

  if ([self.flutterEngines.allKeys containsObject:entrypoint]) {
    block();
  } else {
    ThrioLogV(@"push in startupWithEntrypoint:%@", entrypoint);
    ThrioFlutterEngine *flutterEngine = [[ThrioFlutterEngine alloc] init];
    [self.flutterEngines setObject:flutterEngine forKey:entrypoint];
    [flutterEngine startupWithEntrypoint:entrypoint readyBlock:block];
  }
}

- (FlutterEngine *)getEngineByEntrypoint:(NSString *)entrypoint {
  if (!ThrioNavigator.isMultiEngineEnabled) {
    entrypoint = @"";
  }
  ThrioFlutterEngine *flutterEngine = self.flutterEngines[entrypoint];
  return flutterEngine.engine;
}

- (ThrioChannel *)getChannelByEntrypoint:(NSString *)entrypoint {
  if (!ThrioNavigator.isMultiEngineEnabled) {
    entrypoint = @"";
  }
  
  ThrioFlutterEngine *flutterEngine = self.flutterEngines[entrypoint];
  return flutterEngine.channel;
}

- (void)pushViewController:(ThrioFlutterViewController *)viewController {
  ThrioFlutterEngine *flutterEngine = self.flutterEngines[viewController.entrypoint];
  [flutterEngine pushViewController:viewController];
}

- (void)popViewController:(ThrioFlutterViewController *)viewController {
  ThrioFlutterEngine *flutterEngine = self.flutterEngines[viewController.entrypoint];
  if ([flutterEngine popViewController:viewController] < 1) {
    if (ThrioNavigator.isMultiEngineEnabled &&
        _flutterEngines.count > 1 &&
        flutterEngine.registerUrlCount < ThrioNavigator.multiEngineKeepAliveUrlCount) {
      [self.flutterEngines removeObjectForKey:viewController.entrypoint];
    }
  }
}

- (void)registerFlutterUrls:(NSArray *)urls {
  [self.flutterUrls addObjectsFromArray:urls];
  [self recalculateUrlsCount];
}

- (void)unregisterFlutterUrls:(NSArray *)urls {
  [self.flutterUrls minusSet:[NSSet setWithArray:urls]];
  [self recalculateUrlsCount];
}

#pragma mark - private methods

- (void)recalculateUrlsCount {
  NSMutableDictionary *kvs = [NSMutableDictionary dictionary];
  
  for (NSString *url in self.flutterUrls) {
    NSString *entrypoint = [url componentsSeparatedByString:@"/"].firstObject;
    if (![kvs.allKeys containsObject:entrypoint]) {
      kvs[entrypoint] = @1;
    } else {
      NSNumber *v = kvs[entrypoint];
      kvs[entrypoint] = @(v.integerValue + 1);
    }
  }

  for (NSString *entrypoint in kvs) {
    ThrioFlutterEngine *flutterEngine = self.flutterEngines[entrypoint];
    flutterEngine.registerUrlCount = [kvs[entrypoint] integerValue];
  }
}

@end
