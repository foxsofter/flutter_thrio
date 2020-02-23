//
//  UINavigationController+PopDisabled.m
//  thrio
//
//  Created by fox softer on 2020/2/22.
//

#import <objc/runtime.h>
#import "UINavigationController+PopDisabled.h"
#import "UINavigationController+Navigator.h"
#import "UIViewController+PopDisabled.h"

@implementation UINavigationController (PopDisabled)

- (void)thrio_setPopDisabledUrl:(NSString *)url
                          index:(NSNumber *)index
                       disabled:(BOOL)disabled {
  UIViewController *vc = [self getViewControllerByUrl:url index:index];
  [vc thrio_setPopDisabledUrl:url index:index disabled:disabled];
}

@end
