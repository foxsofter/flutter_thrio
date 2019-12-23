//
//  ThrioFlutterApp.m
//  thrio
//
//  Created by foxsofter on 2019/12/19.
//

#import <Flutter/Flutter.h>
#import "ThrioFlutterApp.h"
#import "../Router/ThrioFlutterPage.h"

@interface ThrioFlutterApp ()

@property (nonatomic, strong, readwrite) FlutterEngine *engine;

@property (nonatomic, strong) ThrioFlutterPage *emptyPage;

@end

@implementation ThrioFlutterApp

+ (instancetype)shared {
  static ThrioFlutterApp *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[ThrioFlutterApp alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _engine = [[FlutterEngine alloc] initWithName:@"__thrio__"];
  }
  return self;
}

- (ThrioFlutterPage *)page {
  if (_engine.viewController != _emptyPage) {
    return (ThrioFlutterPage*)_engine.viewController;
  }
  return nil;
}

- (void)attach:(ThrioFlutterPage *)page {
  if (_engine.viewController != page) {
    [(ThrioFlutterPage*)_engine.viewController surfaceUpdated:NO];
    _engine.viewController = page;
  }
}

- (void)detach {
  if (_engine.viewController != _emptyPage) {
    _engine.viewController = _emptyPage;
  }
}

- (void)inactive {
  
}

- (void)pause {
  
}

- (void)resume {
  
}


@end
