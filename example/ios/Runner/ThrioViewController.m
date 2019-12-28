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

@end

@implementation ThrioViewController

- (IBAction)pushFlutterPage:(id)sender {
  [ThrioRouter.shared push:@"page1"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
