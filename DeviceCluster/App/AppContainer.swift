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
    
//    MPC
    private let peerService: PeerService = PeerServiceImpl()
    
//    Repositories
    private func makePeerRepository() -> PeerRepository {
        PeerRepositoryImpl(secureStorage: secureStorage,
                           peerService: peerService)
    }

//    MARK: - Domain
//    Services
    private func makePeerIDService() -> PeerIDService {
        PeerIDServiceImpl(peerRepository: makePeerRepository())
    }
    
//    Use Cases
    private func makeStartObservingPeersUseCase() -> StartObservingPeersUseCase {
        StartObservingPeersUseCaseImpl(peerRepository: makePeerRepository(),
                                       peerIDService: makePeerIDService())
    }
    
    private func makeConnectWithPeerUseCase() -> ConnectWithPeerUseCase {
        ConnectWithPeerUseCaseImpl(peerRepository: makePeerRepository())
    }
    
    private func makeObservePeersUseCase() -> ObservePeersUseCase {
        ObservePeersUseCaseImpl(peerRepository: makePeerRepository())
    }
    
//    MARK: - Features
    func makeHomeView(router: Router) -> some View {
        let vm = HomeViewModel(router: router,
                               startObservingPeers: makeStartObservingPeersUseCase(),
                               observePeers: makeObservePeersUseCase(),
                               connectWithPeer: makeConnectWithPeerUseCase())
        return HomeView(vm: vm)
    }
}
