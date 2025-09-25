//
//  HomeViewModel.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-25.
//

import Observation
import SwiftUI

@Observable
@MainActor
final class HomeViewModel {
    @ObservationIgnored private unowned let router: Router
    @ObservationIgnored private let startObservingPeers: StartObservingPeersUseCase
    @ObservationIgnored private let connectWithPeer: ConnectWithPeerUseCase
    @ObservationIgnored private let observePeers: ObservePeersUseCase
    private var peersTask: Task<Void, Never>?
    
    var isLoading = false
    var error: String?
    var peers: [PeerUI] = []
    
    init(router: Router,
         startObservingPeers: StartObservingPeersUseCase,
         observePeers: ObservePeersUseCase,
         connectWithPeer: ConnectWithPeerUseCase) {
        self.router = router
        self.startObservingPeers = startObservingPeers
        self.observePeers = observePeers
        self.connectWithPeer = connectWithPeer
    }

    func willAppear() {
        Task {
            try await startObservingPeers.execute()
        }
        
        peersTask?.cancel()
        peersTask = Task { [weak self] in
            guard let self else { return }
            for await items in observePeers.execute() {
                self.peers = items.map { .init(id: $0.id) }
            }
        }
    }

    func didDisappear() {
        peersTask?.cancel()
        peersTask = nil
    }
}
