//
//  KeychainSecureStorage.swift
//  HashtagGenerator
//
//  Created by Daniyar Kurmanbayev on 2025-08-27.
//

import Foundation

public actor KeychainSecureStorage: SecureStorage {
    private let store: KeychainStore
    public init(service: String, accessGroup: String? = nil) {
        self.store = KeychainStore(config: .init(service: service, accessGroup: accessGroup))
    }
    public func put(_ data: Data, key: String,
                    accessibility: KCAccessibility = .whenUnlockedThisDeviceOnly,
                    synchronizable: Bool = false) async throws {
        try await store.set(data, for: key, accessibility: accessibility, synchronizable: synchronizable)
    }
    public func putProtected(_ data: Data, key: String,
                             accessControl: KCAccessControl,
                             synchronizable: Bool = false) async throws {
        try await store.setProtected(data, for: key, accessControl: accessControl, synchronizable: synchronizable)
    }
    public func get(_ key: String) async throws -> Data {
        try await store.get(key)
    }
    public func remove(_ key: String) async throws {
        try await store.delete(key)
    }
}
