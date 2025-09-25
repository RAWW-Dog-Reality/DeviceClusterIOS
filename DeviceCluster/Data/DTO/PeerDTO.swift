//
//  PeerDTO.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-25.
//

struct PeerDTO {
    let id: String
    var connectionStatus: ConnectionStatus = .disconnected
}

extension PeerDTO {
    enum ConnectionStatus {
        case connected
        case disconnected
    }
}
