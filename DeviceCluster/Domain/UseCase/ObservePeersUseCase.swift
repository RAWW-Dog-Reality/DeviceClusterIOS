//
//  ObservePeersUseCase.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-25.
//

protocol ObservePeersUseCase {
    func execute() -> AsyncStream<[Peer]>
}

final class ObservePeersUseCaseFakeImpl: ObservePeersUseCase {
    func execute() -> AsyncStream<[Peer]> {
        AsyncStream { continuation in
            continuation.yield([.init(id: "1"), .init(id: "2")])
            continuation.finish()
        }
    }
}

final class ObservePeersUseCaseImpl: ObservePeersUseCase {
    private let peerRepository: PeerRepository

    init(peerRepository: PeerRepository) {
        self.peerRepository = peerRepository
    }

    func execute() -> AsyncStream<[Peer]> {
        peerRepository.observePeers()
    }
}
