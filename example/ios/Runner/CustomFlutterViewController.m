//
//  CustomFlutterViewController.m
//  Runner
//
//  Created by foxsofter on 2020/11/6.
//  Copyright © 2020 foxsofter. All rights reserved.
//

#import "CustomFlutterViewController.h"

@interface CustomFlutterViewController ()

@property (nonatomic) ThrioChannel *channel;

@end

@implementation CustomFlutterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    _channel = [ThrioChannel channelWithEntrypoint:self.entrypoint name:@"custom_thrio_channel"];
//    [_channel setupMethodChannel:[ThrioNavigator getEngineByEntrypoint:self.entrypoint].binaryMessenger];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [_channel invokeMethod:@"sayHello"];
}

@end
