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

#import <Flutter/Flutter.h>
#import "NavigatorFlutterEngine.h"
#import "NavigatorPageNotifyProtocol.h"
#import "FlutterThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigatorFlutterViewController : FlutterViewController <UINavigationControllerDelegate>

- (instancetype)initWithEngine:(NavigatorFlutterEngine *)engine NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *_Nullable)nibNameOrNil
                         bundle:(NSBundle *_Nullable)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithEngine:(FlutterEngine *)engine
                       nibName:(NSString *_Nullable)nibName
                        bundle:(NSBundle *_Nullable)nibBundle NS_UNAVAILABLE;
- (instancetype)initWithProject:(FlutterDartProject *_Nullable)project
                        nibName:(NSString *_Nullable)nibName
                         bundle:(NSBundle *_Nullable)nibBundle NS_UNAVAILABLE;
- (instancetype)initWithProject:(nullable FlutterDartProject *)project
                   initialRoute:(nullable NSString *)initialRoute
                        nibName:(nullable NSString *)nibName
                         bundle:(nullable NSBundle *)nibBundle NS_UNAVAILABLE;

- (void)surfaceUpdated:(BOOL)appeared;

@property (nonatomic, copy, readonly) NSString *entrypoint;

@property (nonatomic, weak, readonly) NavigatorFlutterEngine *warpEngine;

@end

NS_ASSUME_NONNULL_END
