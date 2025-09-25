//
//  PeerIDService.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-25.
//

import Foundation

protocol PeerIDService {
    func getPeerID() async throws -> String
}

final class PeerIDServiceImpl: PeerIDService {
    private let peerRepository: PeerRepository
    
    init(peerRepository: PeerRepository) {
        self.peerRepository = peerRepository
    }
    
    func getPeerID() async throws -> String {
        if let peerID = try await peerRepository.getMySavedPeerID() {
            return peerID
        }
        
        let suffix = UUID().uuidString.prefix(23)
        let name = "\(Constants.AppConfiguration.peerIDPrefix)\(suffix)"
        try await peerRepository.save(myPeerID: name)
        return name
    }
}
