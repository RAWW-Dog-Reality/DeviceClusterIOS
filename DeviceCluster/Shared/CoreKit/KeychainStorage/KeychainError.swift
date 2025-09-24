//
//  KeychainError.swift
//  HashtagGenerator
//
//  Created by Daniyar Kurmanbayev on 2025-08-27.
//

import Foundation

public enum KeychainError: Error {
    case duplicate, notFound, authFailed, unexpectedStatus(OSStatus), invalidData
}
