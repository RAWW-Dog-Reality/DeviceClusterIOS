//
//  StartObservingPeersUseCase.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-25.
//

protocol StartObservingPeersUseCase {
    func execute() async throws
}

final class StartObservingPeersUseCaseFakeImpl: StartObservingPeersUseCase {
    func execute() async throws {}
}

final class StartObservingPeersUseCaseImpl: StartObservingPeersUseCase {
    private let peerRepository: PeerRepository
    private let peerIDService: PeerIDService
    
    init(peerRepository: PeerRepository,
         peerIDService: PeerIDService) {
        self.peerRepository = peerRepository
        self.peerIDService = peerIDService
    }
    
    func execute() async throws {
        do {
            let myPeerID = try await peerIDService.getPeerID()
            peerRepository.startObservingPeers(myPeerID: myPeerID)
        } catch {
            throw DomainError.couldntGetMyPeerID
        }
    }
}
