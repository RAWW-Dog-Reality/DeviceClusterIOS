//
//  ConnectWithPeerUseCase.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-25.
//

protocol ConnectWithPeerUseCase {
    func execute(peerID: String) async throws
}

final class ConnectWithPeerUseCaseFakeImpl: ConnectWithPeerUseCase {
    func execute(peerID: String) async throws {}
}

final class ConnectWithPeerUseCaseImpl: ConnectWithPeerUseCase {
    private let peerRepository: PeerRepository
    
    init(peerRepository: PeerRepository) {
        self.peerRepository = peerRepository
    }
    
    func execute(peerID: String) async throws {
        try await peerRepository.connect(with: peerID)
    }
}
