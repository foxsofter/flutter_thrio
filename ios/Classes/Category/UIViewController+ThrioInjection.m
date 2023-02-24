// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

#import <objc/runtime.h>
#import "UIViewController+ThrioInjection.h"
#import "NSObject+ThrioSwizzling.h"
#import "ThrioRegistrySetMap.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController ()

@property (nonatomic, strong, nullable) ThrioRegistrySetMap *thrio_beforeBlocks;

@property (nonatomic, strong, nullable) ThrioRegistrySetMap *thrio_afterBlocks;

@end

@implementation UIViewController (ThrioInjection)

- (ThrioVoidCallback)registerInjectionBlock:(ThrioViewControllerLifecycleInjectionBlock)block
                            beforeLifecycle:(ThrioViewControllerLifecycle)lifecycle {
    if (!self.thrio_beforeBlocks) {
        self.thrio_beforeBlocks = [ThrioRegistrySetMap map];
    }
    return [self.thrio_beforeBlocks registry:@(lifecycle) value:block];
}

- (ThrioVoidCallback)registerInjectionBlock:(ThrioViewControllerLifecycleInjectionBlock)block
                             afterLifecycle:(ThrioViewControllerLifecycle)lifecycle {
    if (!self.thrio_afterBlocks) {
        self.thrio_afterBlocks = [ThrioRegistrySetMap map];
    }
    return [self.thrio_afterBlocks registry:@(lifecycle) value:block];
}

- (ThrioRegistrySetMap *_Nullable)thrio_beforeBlocks {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setThrio_beforeBlocks:(ThrioRegistrySetMap *_Nullable)blocks {
    objc_setAssociatedObject(self,
                             @selector(thrio_beforeBlocks),
                             blocks,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ThrioRegistrySetMap *_Nullable)thrio_afterBlocks {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setThrio_afterBlocks:(ThrioRegistrySetMap *_Nullable)blocks {
    objc_setAssociatedObject(self,
                             @selector(thrio_afterBlocks),
                             blocks,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self instanceSwizzle:@selector(viewWillAppear:)
                  newSelector:@selector(thrioInjection_viewWillAppear:)];
        [self instanceSwizzle:@selector(viewDidAppear:)
                  newSelector:@selector(thrioInjection_viewDidAppear:)];
        [self instanceSwizzle:@selector(viewWillDisappear:)
                  newSelector:@selector(thrioInjection_viewWillDisappear:)];
        [self instanceSwizzle:@selector(viewDidDisappear:)
                  newSelector:@selector(thrioInjection_viewDidDisappear:)];
    });
}

- (void)thrioInjection_viewWillAppear:(BOOL)animated {
    NSSet *blocks = self.thrio_beforeBlocks[@(ThrioViewControllerLifecycleViewWillAppear)];
    if (blocks) {
        for (ThrioViewControllerLifecycleInjectionBlock block in blocks) {
            block(self, animated);
        }
    }

    [self thrioInjection_viewWillAppear:animated];

    blocks = self.thrio_afterBlocks[@(ThrioViewControllerLifecycleViewWillAppear)];
    if (blocks) {
        for (ThrioViewControllerLifecycleInjectionBlock block in blocks) {
            block(self, animated);
        }
    }
}

- (void)thrioInjection_viewDidAppear:(BOOL)animated {
    NSSet *blocks = self.thrio_beforeBlocks[@(ThrioViewControllerLifecycleViewDidAppear)];
    if (blocks) {
        for (ThrioViewControllerLifecycleInjectionBlock block in blocks) {
            block(self, animated);
        }
    }

    [self thrioInjection_viewDidAppear:animated];

    blocks = self.thrio_afterBlocks[@(ThrioViewControllerLifecycleViewDidAppear)];
    if (blocks) {
        for (ThrioViewControllerLifecycleInjectionBlock block in blocks) {
            block(self, animated);
        }
    }
}

- (void)thrioInjection_viewWillDisappear:(BOOL)animated {
    NSSet *blocks = self.thrio_beforeBlocks[@(ThrioViewControllerLifecycleViewWillDisappear)];
    if (blocks) {
        for (ThrioViewControllerLifecycleInjectionBlock block in blocks) {
            block(self, animated);
        }
    }

    [self thrioInjection_viewWillDisappear:animated];

    blocks = self.thrio_afterBlocks[@(ThrioViewControllerLifecycleViewWillDisappear)];
    if (blocks) {
        for (ThrioViewControllerLifecycleInjectionBlock block in blocks) {
            block(self, animated);
        }
    }
}

- (void)thrioInjection_viewDidDisappear:(BOOL)animated {
    NSSet *blocks = self.thrio_beforeBlocks[@(ThrioViewControllerLifecycleViewDidDisappear)];
    if (blocks) {
        for (ThrioViewControllerLifecycleInjectionBlock block in blocks) {
            block(self, animated);
        }
    }

    [self thrioInjection_viewDidDisappear:animated];

    blocks = self.thrio_afterBlocks[@(ThrioViewControllerLifecycleViewDidDisappear)];
    if (blocks) {
        for (ThrioViewControllerLifecycleInjectionBlock block in blocks) {
            block(self, animated);
        }
    }
}

@end

NS_ASSUME_NONNULL_END
