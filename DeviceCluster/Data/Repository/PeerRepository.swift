//
//  PeerRepository.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-25.
//

import Foundation

protocol PeerRepository {
    func getMySavedPeerID() async throws -> String?
    func save(myPeerID: String) async throws
    func startObservingPeers(myPeerID: String)
    func connect(with peerID: String) async throws
    func observePeers() -> AsyncStream<[Peer]>
    func sendDataToConnectedPeers(_ data: Data) throws
}

final class PeerRepositoryImpl: PeerRepository {
    private let secureStorage: SecureStorage
    private let peerService: PeerService
    
    init(secureStorage: SecureStorage,
         peerService: PeerService) {
        self.secureStorage = secureStorage
        self.peerService = peerService
    }
    
    func getMySavedPeerID() async throws -> String? {
        do {
            return try await secureStorage.getString(Constants.Storage.Keys.peerID)
        } catch KeychainError.notFound {
            return nil
        }
    }
    
    func save(myPeerID: String) async throws {
        try await secureStorage.putString(myPeerID, key: Constants.Storage.Keys.peerID)
    }
    
    func startObservingPeers(myPeerID: String) {
        peerService.start(myPeerID: myPeerID)
    }
    
    func connect(with peerID: String) async throws {
        try await peerService.connect(with: peerID)
    }
    
    func observePeers() -> AsyncStream<[Peer]> {
        let stream = peerService.peersStream()
        return AsyncStream { continuation in
            let task = Task {
                for await items in stream {
                    let mapped = items.map { Peer(id: $0.getID(),
                                                  isConnected: $0.isConnected) }
                    continuation.yield(mapped)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    func sendDataToConnectedPeers(_ data: Data) throws {
        try peerService.sendDataToConnectedPeers(data)
    }
}
