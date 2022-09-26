// The MIT License (MIT)
//
// Copyright (c) 2022 foxsofter
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

NS_ASSUME_NONNULL_BEGIN

@interface ThrioFlutterEngine : FlutterEngine

/**
 * Initialize this FlutterEngine.
 *
 * A newly initialized engine will not run until either `-runWithEntrypoint:` or `-runWithEntrypoint:libraryURI:` is called.
 *
 * @param labelPrefix The label prefix used to identify threads for this instance. Should
 *   be unique across FlutterEngine instances, and is used in instrumentation to label
 *   the threads used by this FlutterEngine.
 * @param allowHeadlessExecution Whether or not to allow this instance to continue
 *   running after passing a nil `FlutterViewController` to `-setViewController:`.
 */
- (instancetype)initWithName:(NSString *)labelPrefix
      allowHeadlessExecution:(BOOL)allowHeadlessExecution;

/**
 * Creates a running `FlutterEngine` that shares components with this engine
 * @param entrypoint The name of a top-level function from a Dart library.  If this is
 *   FlutterDefaultDartEntrypoint (or nil); this will default to `main()`.  If it is not the app's
 *   main() function, that function must be decorated with `@pragma(vm:entry-point)` to ensure the
 *   method is not tree-shaken by the Dart compiler..
 */
- (ThrioFlutterEngine*)forkWithEntrypoint:(NSString *)entrypoint
                         withInitialRoute:(nullable NSString *)initialRoute
                            withArguments:(nullable NSArray *)arguments;

@end

NS_ASSUME_NONNULL_END
