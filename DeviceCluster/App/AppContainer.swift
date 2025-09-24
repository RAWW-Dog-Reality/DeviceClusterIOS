//
//  Components.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-24.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
final class AppContainer {
//    MARK: - Data
//    Secure Storage
    private let secureStorage: SecureStorage = KeychainSecureStorage(service: Constants.Storage.secureStorageServiceName)

//    MARK: - Services
    private lazy var peerService: PeerService = PeerServiceImpl(secureStorage: secureStorage)
    
//    MARK: - Features
    func makeHomeView() -> some View {
        ContentView(peerService: peerService)
    }
}
