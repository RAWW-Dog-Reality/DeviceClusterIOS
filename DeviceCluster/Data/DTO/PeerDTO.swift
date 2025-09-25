//
//  PeerDTO.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-25.
//

import MultipeerConnectivity

struct PeerDTO {
    let peerID: MCPeerID
    var isConnected = false
}

extension PeerDTO {
    func getID() -> String {
        peerID.displayName
    }
}
