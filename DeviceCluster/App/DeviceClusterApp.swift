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
    
    var body: some Scene {
        WindowGroup {
            container.makeHomeView()
        }
    }
}
