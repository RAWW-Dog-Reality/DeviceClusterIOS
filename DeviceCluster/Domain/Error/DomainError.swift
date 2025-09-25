//
//  DomainError.swift
//  HashtagGenerator
//
//  Created by Daniyar Kurmanbayev on 2025-08-26.
//

import Foundation

enum DomainError: LocalizedError {
    case couldntGetMyPeerID
    
    var errorDescription: String? {
        switch self {
        case .couldntGetMyPeerID:
            return "Could not get the peer ID"
        }
    }
}
