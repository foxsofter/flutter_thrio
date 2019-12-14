//
//  ThrioRouterContainer.m
//  thrio_router
//
//  Created by Wei ZhongDan on 2019/12/11.
//

#import "ThrioRouterContainer.h"

@interface ThrioRouterContainer ()

@property (nonatomic, copy, readwrite) NSString *url;

@property (nonatomic, strong, readwrite) NSNumber *index;

@property (nonatomic, copy, readwrite) NSDictionary *params;

@end

@implementation ThrioRouterContainer

- (instancetype)init {
  
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setUrl:(NSString *)url params:(NSDictionary *)params {
  if (!_url && url) {
    _url = url;
    _params = params;
  }
}

static NSMutableDictionary *kIndexs;

@end
