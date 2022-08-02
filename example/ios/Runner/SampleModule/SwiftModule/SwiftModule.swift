//
//  SwiftModule.swift
//  Runner
//
//  Created by foxsofter on 2020/10/30.
//  Copyright © 2020 foxsofter. All rights reserved.
//

import Foundation
import SwiftUI
import flutter_thrio

class SwiftPageObserver: NSObject, NavigatorPageObserverProtocol {
}

class SwiftRouteObserver: NSObject, NavigatorRouteObserverProtocol {
}

class SwiftModule: ThrioModule {
    override func onModuleInit(_ moduleContext: ThrioModuleContext) {
    }
    
    override func onPageBuilderRegister(_ moduleContext: ThrioModuleContext) {
        _ = register({ (_) -> UIViewController? in
            if #available(iOS 13.0, *) {
                return UIHostingController(rootView: Page5View())
            } else {
                return UIViewController()
            }
        }, forUrl: "/biz1/swift1")
    }

    override func onPageObserverRegister(_ moduleContext: ThrioModuleContext) {
        _ = register(SwiftPageObserver())
    }

    override func onRouteObserverRegister(_ moduleContext: ThrioModuleContext) {
        _ = register(SwiftRouteObserver())
    }
    
    override func onJsonSerializerRegister(_ moduleContext: ThrioModuleContext) {
        
    }
    
    override func onJsonDeserializerRegister(_ moduleContext: ThrioModuleContext) {
        
    }
}
