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
  [ThrioRouter.shared push:@"flutter1"];
}
- (IBAction)popFlutter1:(id)sender {
  [ThrioRouter.shared pop:@"flutter1"];
}
- (IBAction)pushNativePage:(id)sender {
  [ThrioRouter.shared push:@"native1"];
}
- (IBAction)popNative1:(id)sender {
  [ThrioRouter.shared pop:@"native1"];
}

- (void)viewDidLoad {
  [super viewDidLoad];
    // Do any additional setup after loading the view.
  if (self.pageUrl) {
    NSString *txt = [NSString stringWithFormat:@"native page: %@ \n index: %@", self.pageUrl, self.pageIndex];
    [self.label setText:txt];
  }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
