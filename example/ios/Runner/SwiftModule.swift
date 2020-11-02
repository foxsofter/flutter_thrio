//
//  SwiftModule.swift
//  Runner
//
//  Created by foxsofter on 2020/10/30.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
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

    override func onPageRegister() {
        _ = register(SwiftPageObserver())
        _ = register(SwiftRouteObserver())
        _ = register({ (params) -> UIViewController? in
            if #available(iOS 13.0, *) {
                return UIHostingController(rootView: Page5View())
            } else {
                return UIViewController()
            }
        }, forUrl: "/biz1/swift1")
    }
}
