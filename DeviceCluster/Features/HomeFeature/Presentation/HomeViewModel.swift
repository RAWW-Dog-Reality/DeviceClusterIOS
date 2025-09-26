//
//  HomeViewModel.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-25.
//

import Observation
import SwiftUI
import Foundation
import AVFoundation

@Observable
@MainActor
final class HomeViewModel {
    @ObservationIgnored private unowned let router: Router
    @ObservationIgnored private let startObservingPeers: StartObservingPeersUseCase
    @ObservationIgnored private let connectWithPeer: ConnectWithPeerUseCase
    @ObservationIgnored private let observePeers: ObservePeersUseCase
    @ObservationIgnored private let sendTestAudio: SendTestAudioUseCase
    @ObservationIgnored private let observeAudio: ObserveAudioUseCase
    private var peersTask: Task<Void, Never>?
    private var incomingAudioTask: Task<Void, Never>?
    private var player: AVAudioPlayer?
    
    var isLoading = false
    var error: String?
    var peers: [PeerUI] = []
    var hasConnectedPeer: Bool { peers.contains(where: { $0.isConnected }) }
    var latestReceivedAudio: Data?
    var hasAudio: Bool { latestReceivedAudio != nil }
    
    init(router: Router,
         startObservingPeers: StartObservingPeersUseCase,
         observePeers: ObservePeersUseCase,
         connectWithPeer: ConnectWithPeerUseCase,
         sendTestAudio: SendTestAudioUseCase,
         observeAudio: ObserveAudioUseCase) {
        self.router = router
        self.startObservingPeers = startObservingPeers
        self.observePeers = observePeers
        self.connectWithPeer = connectWithPeer
        self.sendTestAudio = sendTestAudio
        self.observeAudio = observeAudio
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
        
        incomingAudioTask?.cancel()
        incomingAudioTask = Task { [weak self] in
            guard let self else { return }
            for await data in observeAudio.execute() {
                self.latestReceivedAudio = data
            }
        }
    }

    func didDisappear() {
        peersTask?.cancel()
        peersTask = nil
        
        incomingAudioTask?.cancel()
        incomingAudioTask = nil
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
    
    func playReceivedAudioTapped() {
        guard let audio = latestReceivedAudio else { return }
        
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [])
        try? session.setActive(true, options: [])

        player = try? AVAudioPlayer(data: audio)
        player?.prepareToPlay()
        player?.play()
    }
}
