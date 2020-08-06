//
//  ThrioViewController.m
//  Runner
//
//  Created by foxsofter on 2019/12/25.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "ThrioViewController.h"
#import <thrio/Thrio.h>
#import <Flutter/Flutter.h>
#import <SSZipArchive/SSZipArchive.h>

@interface ThrioViewController ()<NavigatorPageNotifyProtocol>

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ThrioViewController

- (IBAction)pushFlutterPage:(id)sender {
//  [ThrioNavigator pushUrl:@"/biz1/flutter1"];
    
    NSString* flutterAssetsName = [[NSBundle mainBundle] pathForResource:@"flutter_assets" ofType:@"zip"];
    
    NSString *unzipPath = [self tempUnzipPath];
    
    [SSZipArchive unzipFileAtPath:flutterAssetsName toDestination:unzipPath];
    NSLog(@"flutter_assets path: %@", unzipPath);

    NSString *bin = [NSString stringWithFormat:@"%@/flutter_assets/kernel_blob.bin", unzipPath];
    NSLog(@"bin path: %@", bin);
    if (![NSFileManager.defaultManager fileExistsAtPath:bin]) {
        @throw @1;
    }

    FlutterDartProject *project = [[FlutterDartProject alloc] initWithFlutterAssetsURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@/flutter_assets", unzipPath]] ];

//    FlutterEngine *engine = [[FlutterEngine alloc] initWithName:@"hahaha" project:project allowHeadlessExecution:YES];
    
    FlutterViewController *vc = [[FlutterViewController alloc] initWithProject:project nibName:nil bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.navigationController.navigationBarHidden = YES;
    });
}

- (NSString *)tempUnzipPath {
    NSString *path = [NSString stringWithFormat:@"%@",
                      NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
                      ];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:url
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&error];
    if (error) {
        return nil;
    }
    return url.path;
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
  [ThrioNavigator pushUrl:@"native1"];
}
- (IBAction)popNative1:(id)sender {
  [ThrioNavigator removeUrl:@"native1"];
}
- (IBAction)pushNative2:(id)sender {
  [ThrioNavigator pushUrl:@"native2" poppedResult:^(id _Nullable params) {
    ThrioLogV(@"native2 popped: %@", params);
  }];
}
- (IBAction)popNative2:(id)sender {
  [ThrioNavigator removeUrl:@"native2"];
}
- (IBAction)pop:(id)sender {
  [ThrioNavigator pop];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  if (self.thrio_firstRoute.settings) {
    NSString *txt = [NSString stringWithFormat:@"native page: %@ \n index: %@",
                     self.thrio_firstRoute.settings.url,
                     self.thrio_firstRoute.settings.index];
    [self.label setText:txt];
  } else {
    // 只是给根部的ViewController标记url和index，这样才能定位到这个页面
    [self thrio_pushUrl:@"native1"
                  index:@1
                 params:nil
               animated:NO
         fromEntrypoint:nil
                 result:nil
           poppedResult:nil];
  }
}

- (void)onNotify:(NSString *)name params:(id)params {
  ThrioLogV(@"native1 onNotify: %@, %@", name, params);
}

@end
