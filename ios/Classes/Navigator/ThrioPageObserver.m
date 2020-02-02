//
//  ThrioPageObserver.m
//  thrio
//
//  Created by Wei ZhongDan on 2020/2/2.
//

#import "ThrioPageObserver.h"
#import "ThrioApp.h"
#import "UINavigationController+ThrioNavigator.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioPageObserver ()

@property (nonatomic, strong) ThrioChannel *channel;

@end

@implementation ThrioPageObserver

- (instancetype)initWithChannel:(ThrioChannel *)channel {
  self = [super init];
  if (self) {
    _channel = channel;
    [self _onPush];
    [self _onNotify];
    [self _onPop];
    [self _onPopTo];
    [self _onRemove];
    [self _onDidPush];
    [self _onDidPop];
    [self _onDidPopTo];
    [self _onDidRemove];
    [self _onLastIndex];
    [self _onGetAllIndex];
    [self _onSetPopDisabled];
  }
  return self;
}

#pragma mark - on channel methods

- (void)_onNotify {
  [_channel registryMethodCall:@"notify"
                       handler:^void(NSDictionary<NSString *,id> * arguments,
                                     ThrioBoolCallback _Nullable result) {
    NSString *name = arguments[@"name"];
    if (name.length < 1) {
      if (result) {
        result(NO);
      }
      return;
    }
    NSString *url = arguments[@"url"];
    if (url.length < 1) {
      if (result) {
        result(NO);
      }
      return;
    }
    NSNumber *index = arguments[@"index"];
    NSDictionary *params = arguments[@"params"];
    [ThrioApp.shared notifyUrl:url index:index name:name params:params result:^(BOOL r) {
      if (result) {
        result(r);
      }
    }];
  }];
}

- (void)_onPush {
  [_channel registryMethodCall:@"push"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    if (url.length < 1) {
      if (result) {
        result(NO);
      }
      return;
    }
    BOOL animated = [arguments[@"animated"] boolValue];
    NSDictionary *params = arguments[@"params"];
    [ThrioApp.shared pushUrl:url params:params animated:animated result:^(BOOL r) {
      result(r);
    }];
  }];
}

- (void)_onPop {
  [_channel registryMethodCall:@"pop"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
     BOOL animated = [arguments[@"animated"] boolValue];
     [ThrioApp.shared popAnimated:animated result:^(BOOL r) {
      if (result) {
        result(r);
      }
    }];
  }];
}

- (void)_onPopTo {
  [_channel registryMethodCall:@"popTo"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    if (url.length < 1) {
      if (result) {
        result(NO);
      }
      return;
    }
    NSNumber *index = arguments[@"index"];
    BOOL animated = [arguments[@"animated"] boolValue];
    [ThrioApp.shared popToUrl:url index:index animated:animated result:^(BOOL r) {
      if (result) {
        result(r);
      }
    }];
  }];
}

- (void)_onRemove {
  [_channel registryMethodCall:@"remove"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];
    BOOL animated = [arguments[@"animated"] boolValue];
    [ThrioApp.shared removeUrl:url index:index animated:animated result:^(BOOL r) {
      if (result) {
        result(r);
      }
    }];
  }];
}

- (void)_onLastIndex {
  [_channel registryMethodCall:@"lastIndex"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    if (result) {
      NSString *url = arguments[@"url"];
      if (url.length < 1) {
        result([ThrioApp.shared lastIndex]);
      } else {
        result([ThrioApp.shared getLastIndexByUrl:url]);
      }
    }
  }];
}

- (void)_onGetAllIndex {
  [_channel registryMethodCall:@"allIndex"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
     NSString *url = arguments[@"url"];
     if (result) {
       result([ThrioApp.shared getAllIndexByUrl:url]);
     }
  }];
}

- (void)_onDidPush {
  [_channel registryMethodCall:@"didPush"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];
    [ThrioApp.shared.navigationController thrio_didPushUrl:url index:index];
  }];
}

- (void)_onDidPop {
  [_channel registryMethodCall:@"didPop"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];
    [ThrioApp.shared.navigationController thrio_didPopUrl:url index:index];
  }];
}

- (void)_onDidPopTo {
  [_channel registryMethodCall:@"didPopTo"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];
    [ThrioApp.shared.navigationController thrio_didPopToUrl:url index:index];
  }];
}

- (void)_onDidRemove {
  [_channel registryMethodCall:@"didRemove"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];
    [ThrioApp.shared.navigationController thrio_didRemoveUrl:url index:index];
  }];
}

- (void)_onSetPopDisabled {
  [_channel registryMethodCall:@"setPopDisabled"
                       handler:^void(NSDictionary<NSString *,id> * arguments,
                                     ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];
    BOOL disabled = [arguments[@"disabled"] boolValue];

    [ThrioApp.shared.navigationController thrio_setPopDisabledUrl:url
                                                            index:index
                                                         disabled:disabled];
  }];
}

@end

NS_ASSUME_NONNULL_END
