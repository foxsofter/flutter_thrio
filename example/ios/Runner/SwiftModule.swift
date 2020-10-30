//
//  SwiftModule.swift
//  Runner
//
//  Created by Wei ZhongDan on 2020/10/30.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation
import thrio.Swift

class SwiftPageObserver: NSObject, NavigatorPageObserverProtocol {
}

class SwiftRouteObserver: NSObject, NavigatorRouteObserverProtocol {
}

class SwiftModule: ThrioModule {
    override func onModuleInit() {
        register(SwiftModule())
    }

    override func onPageRegister() {
        _ = register(SwiftPageObserver())
        _ = register(SwiftRouteObserver())
    }
}
