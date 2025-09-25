//
//  HomeViewModel.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-25.
//

import Observation
import SwiftUI
import Foundation

@Observable
@MainActor
final class HomeViewModel {
    @ObservationIgnored private unowned let router: Router
    @ObservationIgnored private let startObservingPeers: StartObservingPeersUseCase
    @ObservationIgnored private let connectWithPeer: ConnectWithPeerUseCase
    @ObservationIgnored private let observePeers: ObservePeersUseCase
    @ObservationIgnored private let sendTestAudio: SendTestAudioUseCase
    private var peersTask: Task<Void, Never>?
    
    var isLoading = false
    var error: String?
    var peers: [PeerUI] = []
    var hasConnectedPeer: Bool { peers.contains(where: { $0.isConnected }) }
    
    init(router: Router,
         startObservingPeers: StartObservingPeersUseCase,
         observePeers: ObservePeersUseCase,
         connectWithPeer: ConnectWithPeerUseCase,
         sendTestAudio: SendTestAudioUseCase) {
        self.router = router
        self.startObservingPeers = startObservingPeers
        self.observePeers = observePeers
        self.connectWithPeer = connectWithPeer
        self.sendTestAudio = sendTestAudio
    }

    func willAppear() {
        Task {
            try await startObservingPeers.execute()
        }
        
        peersTask?.cancel()
        peersTask = Task { [weak self] in
            guard let self else { return }
            for await items in observePeers.execute() {
                self.peers = items.map { .init(id: $0.id, isConnected: $0.isConnected) }
            }
        }
    }

    func didDisappear() {
        peersTask?.cancel()
        peersTask = nil
    }
    
    func peerIdClicked(_ peerId: String) {
        isLoading.toggle()
        Task {
            do {
                try await connectWithPeer.execute(peerID: peerId)
                isLoading.toggle()
            } catch {
                isLoading.toggle()
                self.error = error.localizedDescription
            }
        }
    }
    
    func sendTestAudioTapped() {
        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            do {
                try await sendTestAudio.execute()
                isLoading = false
            } catch {
                isLoading = false
                self.error = error.localizedDescription
            }
        }
    }
}
