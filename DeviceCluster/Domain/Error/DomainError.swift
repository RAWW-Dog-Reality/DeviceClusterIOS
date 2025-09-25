//
//  DomainError.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-08-26.
//

import Foundation

enum DomainError: LocalizedError {
    case generic
    case couldntGetMyPeerID
    
    var errorDescription: String? {
        switch self {
        case .generic:
            return "An unknown error occurred"
        case .couldntGetMyPeerID:
            return "Could not get the peer ID"
        }
    }
}
