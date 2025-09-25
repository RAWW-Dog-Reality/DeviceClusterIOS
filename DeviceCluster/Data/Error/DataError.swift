//
//  DataError.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-08-27.
//

import Foundation

enum DataError: LocalizedError {
    case generic
    case noPeedID
    case failedToConnectWithPeer
    
    var errorDescription: String? {
        switch self {
        case .generic:
            return "Something went wrong. Please try again."
        case .noPeedID:
            return "No peer ID. Please try again."
        case .failedToConnectWithPeer:
            return "Failed to connect with peer. Please try again."
        }
    }
}
