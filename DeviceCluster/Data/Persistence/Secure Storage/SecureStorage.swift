//
//  SecureStorage.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-08-27.
//

import Foundation

public protocol SecureStorage {
    func put(_ data: Data, key: String,
             accessibility: KCAccessibility,
             synchronizable: Bool) async throws
    func putProtected(_ data: Data, key: String,
                      accessControl: KCAccessControl,
                      synchronizable: Bool) async throws
    func get(_ key: String) async throws -> Data
    func remove(_ key: String) async throws
}

public extension SecureStorage {
    func putString(_ value: String, key: String,
                   accessibility: KCAccessibility = .whenUnlockedThisDeviceOnly,
                   synchronizable: Bool = false) async throws {
        try await put(Data(value.utf8), key: key, accessibility: accessibility, synchronizable: synchronizable)
    }
    
    func getString(_ key: String) async throws -> String {
        let data = try await get(key)
        guard let s = String(data: data, encoding: .utf8) else { throw KeychainError.invalidData }
        return s
    }
}
