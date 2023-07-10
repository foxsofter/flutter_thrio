//
//  ThrioViewController2.m
//  Runner
//
//  Created by foxsofter on 2019/12/25.
//  Copyright © 2019 foxsofter. All rights reserved.
//

#import "ThrioViewController2.h"
#import <flutter_thrio/FlutterThrio.h>

@interface ThrioViewController2 ()<NavigatorPageNotifyProtocol>

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ThrioViewController2

- (IBAction)pushFlutterPage:(id)sender {
    [ThrioNavigator pushUrl:@"/biz/biz2/flutter2"
               poppedResult:^(id _Nonnull params) {
        ThrioLogV(@"/biz2/flutter2 popped: %@", params);
    }];
}

- (IBAction)popFlutter1:(id)sender {
    [ThrioNavigator removeUrl:@"/biz/biz2/flutter2"];
}

- (IBAction)pushNativePage:(id)sender {
    [ThrioNavigator pushUrl:@"/biz1/native1"];
}

- (IBAction)popNative1:(id)sender {
    [ThrioNavigator removeUrl:@"/biz1/native1"];
}

- (IBAction)popToNative1:(id)sender {
    [ThrioNavigator popToUrl:@"/biz1/native1"];
}

- (IBAction)pushNative1WithoutThrio:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc =
        [sb instantiateViewControllerWithIdentifier:@"ThrioViewController"];

    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)pop:(id)sender {
    [ThrioNavigator popParams:@{ @"k1": @3 }];
}

- (IBAction)popFlutter:(id)sender {
    [ThrioNavigator popFlutterParams:@{ @"k1": @3 }];
}


- (IBAction)willPopYESNative2:(id)sender {
    self.thrio_willPopBlock = ^(ThrioBoolCallback _Nonnull result) {
        result(YES);
    };
}

- (IBAction)willPopNONative2:(id)sender {
    self.thrio_willPopBlock = ^(ThrioBoolCallback _Nonnull result) {
        result(NO);
    };
}

- (IBAction)willPopNilNative2:(id)sender {
    self.thrio_willPopBlock = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.thrio_firstRoute.settings) {
        NSString *txt =
            [NSString stringWithFormat:@"native page: %@ \n index: %@",
             self.thrio_firstRoute.settings.url,
             self.thrio_firstRoute.settings.index];
        [self.label setText:txt];
    }
    self.thrio_hidesNavigationBar = YES;

    // 禁用手势，可以点击返回键关闭页面
    //  self.thrio_willPopBlock = ^(ThrioBoolCallback _Nonnull result) {
    //    result(YES);
    //  };

    // 禁用手势，也不能点击返回键关闭页面
    //  self.thrio_willPopBlock = ^(ThrioBoolCallback _Nonnull result) {
    //    result(NO);
    //  };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.thrio_hidesNavigationBar = YES;
}

- (void)onNotify:(NSString *)name params:(id)params {
    ThrioLogV(@"/biz2/native2 onNotify: %@, %@", name, params);
}

@end
