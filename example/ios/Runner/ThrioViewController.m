//
//  ThrioViewController.m
//  Runner
//
//  Created by foxsofter on 2019/12/25.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "ThrioViewController.h"
#import <Flutter/Flutter.h>
#import <thrio/Thrio.h>

@interface ThrioViewController () <NavigatorPageNotifyProtocol>

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ThrioViewController

- (IBAction)pushFlutterPage:(id)sender {
    [ThrioNavigator pushUrl:@"/biz1/flutter1" params:@1];
}

- (IBAction)popFlutter1:(id)sender {
    [ThrioNavigator removeUrl:@"/biz1/flutter1"];
}

- (IBAction)pushFlutter2:(id)sender {
    [ThrioNavigator pushUrl:@"/biz2/flutter2"];
}

- (IBAction)popFlutter2:(id)sender {
    [ThrioNavigator removeUrl:@"/biz2/flutter2"];
}

- (IBAction)pushNativePage:(id)sender {
    [ThrioNavigator pushUrl:@"/biz1/native1"];
}

- (IBAction)popNative1:(id)sender {
    [ThrioNavigator removeUrl:@"/biz1/native1"];
}

- (IBAction)pushNative2:(id)sender {
    [ThrioNavigator pushUrl:@"/biz1/native2"
               poppedResult:^(id _Nullable params) {
        ThrioLogV(@"/biz1/native2 popped: %@", params);
    }];
}

- (IBAction)popNative2:(id)sender {
    [ThrioNavigator removeUrl:@"/biz1/native2"];
}

- (IBAction)pop:(id)sender {
    [ThrioNavigator pop];
}

- (IBAction)pushNative1WithNvc:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc =
        [sb instantiateViewControllerWithIdentifier:@"ThrioViewController"];

    UINavigationController *nvc =
        [[UINavigationController alloc] initWithRootViewController:vc];

    [self.navigationController presentViewController:nvc
                                            animated:YES
                                          completion:^{
    }];
}

- (IBAction)dismiss:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:^{
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.thrio_firstRoute.settings) {
        NSString *txt =
            [NSString stringWithFormat:@"native page: %@ \n index: %@",
             self.thrio_firstRoute.settings.url,
             self.thrio_firstRoute.settings.index];
        [self.label setText:txt];
    } else {
        // 只是给根部的ViewController标记url和index，这样才能定位到这个页面
        //        [self thrio_pushUrl:@"/biz1/native1"
        //                      index:@1
        //                     params:nil
        //                   animated:NO
        //             fromEntrypoint:nil
        //                     result:nil
        //               poppedResult:nil];
    }
}

- (void)dealloc {
}

- (void)onNotify:(NSString *)name params:(id)params {
    ThrioLogV(@"/biz1/native1 onNotify: %@, %@", name, params);
}

@end
