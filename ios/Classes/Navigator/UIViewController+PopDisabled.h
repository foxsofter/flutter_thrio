//
//  UIViewController+PopDisabled.h
//  thrio
//
//  Created by fox softer on 2020/2/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (PopDisabled)

- (void)thrio_setPopDisabled:(BOOL)disabled;

- (void)thrio_setPopDisabledUrl:(NSString *)url
                          index:(NSNumber *)index
                       disabled:(BOOL)disabled;

@end

NS_ASSUME_NONNULL_END
