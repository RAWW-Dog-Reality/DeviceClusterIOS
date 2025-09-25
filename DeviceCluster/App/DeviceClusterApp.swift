//
//  DeviceClusterApp.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-24.
//

import SwiftUI

@main
struct DeviceClusterApp: App {
    private let container = AppContainer()
    @StateObject private var router = Router()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                container.makeHomeView(router: router)
            }
//            .navigationDestination(for: Router.Route.self) { route in
//                switch route {
//                }
//            }
//            .sheet(item: $router.sheet) { sheet in
//                switch sheet {
//                }
//            }
        }
    }
}
