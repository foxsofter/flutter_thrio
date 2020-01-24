//
//  ThrioViewController.m
//  Runner
//
//  Created by Wei ZhongDan on 2019/12/25.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "ThrioViewController.h"
#import <thrio/Thrio.h>

@interface ThrioViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ThrioViewController

- (IBAction)pushFlutterPage:(id)sender {
  [ThrioNavigator.shared pushUrl:@"flutter1"];
}
- (IBAction)popFlutter1:(id)sender {
  [ThrioNavigator.shared removeUrl:@"flutter1"];
}
- (IBAction)pushNativePage:(id)sender {
  [ThrioNavigator.shared pushUrl:@"native1"];
}
- (IBAction)popNative1:(id)sender {
  [ThrioNavigator.shared removeUrl:@"native1"];
}
- (IBAction)pop:(id)sender {
  [ThrioNavigator.shared pop];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  if (self.firstRoute.settings) {
    NSString *txt = [NSString stringWithFormat:@"native page: %@ \n index: %@", self.firstRoute.settings.url, self.firstRoute.settings.index];
    [self.label setText:txt];
  }
}

@end
