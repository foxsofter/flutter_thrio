//
//  SwiftModule.swift
//  Runner
//
//  Created by foxsofter on 2020/10/30.
//  Copyright © 2020 foxsofter. All rights reserved.
//

import Foundation
import SwiftUI
import thrio

class SwiftPageObserver: NSObject, NavigatorPageObserverProtocol {
}

class SwiftRouteObserver: NSObject, NavigatorRouteObserverProtocol {
}

class SwiftModule: ThrioModule {
    override func onModuleInit() {
    }

    override func onPageBuilderRegister() {
        _ = register({ (_) -> UIViewController? in
            if #available(iOS 13.0, *) {
                return UIHostingController(rootView: Page5View())
            } else {
                return UIViewController()
            }
        }, forUrl: "/biz1/swift1")
    }

    override func onPageObserverRegister() {
        _ = register(SwiftPageObserver())
    }

    override func onRouteObserverRegister() {
        _ = register(SwiftRouteObserver())
    }
    
    override func onJsonSerializerRegister() {
        
    }
    
    override func onJsonDeserializerRegister() {
        
    }
}
