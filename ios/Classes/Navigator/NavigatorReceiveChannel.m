//
//  NavigatorReceiveChannel.m
//  thrio
//
//  Created by Wei ZhongDan on 2020/2/2.
//

#import "NavigatorReceiveChannel.h"
#import "ThrioNavigator.h"
#import "ThrioNavigator+Internal.h"
#import "UINavigationController+Navigator.h"
#import "UINavigationController+PopDisabled.h"
#import "UINavigationController+HotRestart.h"
#import "ThrioLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorReceiveChannel ()

@property (nonatomic, strong) ThrioChannel *channel;

@property (nonatomic, copy) ThrioVoidCallback readyBlock;

@end

@implementation NavigatorReceiveChannel

- (instancetype)initWithChannel:(ThrioChannel *)channel {
  self = [super init];
  if (self) {
    _channel = channel;
    [self _onReady];
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
    [self _onHotRestart];
  }
  return self;
}

- (void)setReadyBlock:(ThrioVoidCallback)block {
  _readyBlock = block;
}

#pragma mark - on channel methods

- (void)_onReady {
  __weak typeof(self) weakself = self;
  [_channel registryMethodCall:@"ready"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    __strong typeof(self) strongSelf = weakself;
    if (strongSelf.readyBlock) {
      strongSelf.readyBlock();
    }
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

    ThrioLogV(@"on push: %@", url);

    [ThrioNavigator pushUrl:url params:params animated:animated result:^(BOOL r) {
      result(r);
    }];
  }];
}

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
    [ThrioNavigator notifyUrl:url index:index name:name params:params result:^(BOOL r) {
      if (result) {
        result(r);
      }
    }];
  }];
}

- (void)_onPop {
  [_channel registryMethodCall:@"pop"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
     BOOL animated = [arguments[@"animated"] boolValue];

     ThrioLogV(@"on pop");

     [ThrioNavigator popAnimated:animated result:^(BOOL r) {
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
    
    ThrioLogV(@"on popTo: %@.%@", url, index);

    [ThrioNavigator popToUrl:url index:index animated:animated result:^(BOOL r) {
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

    ThrioLogV(@"on remove: %@.%@", url, index);

    [ThrioNavigator removeUrl:url index:index animated:animated result:^(BOOL r) {
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
        result([ThrioNavigator lastIndex]);
      } else {
        result([ThrioNavigator getLastIndexByUrl:url]);
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
       result([ThrioNavigator getAllIndexByUrl:url]);
     }
  }];
}

- (void)_onDidPush {
  [_channel registryMethodCall:@"didPush"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];

    ThrioLogV(@"on didPush: %@.%@", url, index);

    [ThrioNavigator.navigationController thrio_didPushUrl:url index:index];
  }];
}

- (void)_onDidPop {
  [_channel registryMethodCall:@"didPop"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];

    ThrioLogV(@"on didPop: %@.%@", url, index);

    [ThrioNavigator.navigationController thrio_didPopUrl:url index:index];
  }];
}

- (void)_onDidPopTo {
  [_channel registryMethodCall:@"didPopTo"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];

    ThrioLogV(@"on didPopTo: %@.%@", url, index);

    [ThrioNavigator.navigationController thrio_didPopToUrl:url index:index];
  }];
}

- (void)_onDidRemove {
  [_channel registryMethodCall:@"didRemove"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];

    ThrioLogV(@"on didRemove: %@.%@", url, index);

    [ThrioNavigator.navigationController thrio_didRemoveUrl:url index:index];
  }];
}

- (void)_onSetPopDisabled {
  [_channel registryMethodCall:@"setPopDisabled"
                       handler:^void(NSDictionary<NSString *,id> * arguments,
                                     ThrioBoolCallback _Nullable result) {
    NSString *url = arguments[@"url"];
    NSNumber *index = arguments[@"index"];
    BOOL disabled = [arguments[@"disabled"] boolValue];

    [ThrioNavigator.navigationController thrio_setPopDisabledUrl:url
                                                           index:index
                                                        disabled:disabled];
  }];
}

- (void)_onHotRestart {
  [_channel registryMethodCall:@"hotRestart"
                        handler:^void(NSDictionary<NSString *,id> * arguments,
                                      ThrioBoolCallback _Nullable result) {
    [ThrioNavigator.navigationController thrio_hotRestart:^(BOOL r) {
      result(r);
    }];
  }];
}

@end

NS_ASSUME_NONNULL_END
