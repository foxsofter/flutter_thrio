//
//  ThrioViewController2.m
//  Runner
//
//  Created by foxsofter on 2019/12/25.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "ThrioViewController2.h"
#import <thrio/Thrio.h>

@interface ThrioViewController2 ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ThrioViewController2

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
- (IBAction)popToNative1:(id)sender {
  [ThrioNavigator.shared popToUrl:@"native1"];
}
- (IBAction)pop:(id)sender {
  [ThrioNavigator.shared pop];
}
- (IBAction)enableFlutter1Eabled:(id)sender {
  [ThrioNavigator.shared setPopDisabledUrl:@"flutter1" disabled:NO];
}
- (IBAction)disabledFlutter1Eabled:(id)sender {
  [ThrioNavigator.shared setPopDisabledUrl:@"flutter1" disabled:YES];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  if (self.thrio_firstRoute.settings) {
    NSString *txt = [NSString stringWithFormat:@"native page: %@ \n index: %@", self.thrio_firstRoute.settings.url, self.thrio_firstRoute.settings.index];
    [self.label setText:txt];
  }
  
  [ThrioNavigator.shared setPopDisabled:YES];
}

@end
