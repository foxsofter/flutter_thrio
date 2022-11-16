//
//  ThrioModule+private.h
//  Pods
//
//  Created by SH66233ML2 on 2022/11/16.
//

#ifndef ThrioModule_private_h
#define ThrioModule_private_h

#import "ThrioModule.h"

@interface ThrioModule ()

+ (ThrioModule *)rootModule;

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
