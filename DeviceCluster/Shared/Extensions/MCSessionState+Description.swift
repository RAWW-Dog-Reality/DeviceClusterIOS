//
//  MCSessionState.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-24.
//

import MultipeerConnectivity

extension MCSessionState {
    var description: String {
        switch self {
        case .notConnected: return "Not Connected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        @unknown default: return "Unknown"
        }
    }
}
