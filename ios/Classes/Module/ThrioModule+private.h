// The MIT License (MIT)
//
// Copyright (c) 2023 foxsofter
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

#ifndef ThrioModule_private_h
#define ThrioModule_private_h

#import "ThrioModule.h"

@interface ThrioModule ()

+ (ThrioModule *_Nonnull)rootModule;

@property (nonatomic, readwrite, nullable) ThrioModuleContext * moduleContext;

/// Startup the flutter engine with `entrypoint`.
///
/// Should be called in `onModuleAsyncInit:`. Subsequent calls will return immediately if the entrypoint is the same.
///
/// Do not override this method.
///
- (NavigatorFlutterEngine *_Nonnull)startupFlutterEngineWithEntrypoint:(NSString *_Nonnull)entrypoint
                                                    readyBlock:(ThrioEngineReadyCallback _Nullable)block;

@end


#endif /* ThrioModule_private_h */
