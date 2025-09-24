//
//  KeychainStore.swift
//  HashtagGenerator
//
//  Created by Daniyar Kurmanbayev on 2025-08-27.
//

import Foundation
import LocalAuthentication

public final class KeychainStore {
    private let cfg: KeychainConfig
    public init(config: KeychainConfig) { self.cfg = config }
    
    public func set(_ data: Data, for key: String,
                    accessibility: KCAccessibility = .whenUnlockedThisDeviceOnly,
                    synchronizable: Bool = false) throws {
        var query: [String: Any] = baseQuery(for: key)
        query[kSecAttrAccessible as String] = accessibility.value
        query[kSecAttrSynchronizable as String] = synchronizable
        query[kSecValueData as String] = data
        
        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
        case errSecSuccess: return
        case errSecDuplicateItem:
            let updateQuery = baseQuery(for: key, matchOnly: true, synchronizable: synchronizable)
            let attrs = [kSecValueData as String: data]
            let u = SecItemUpdate(updateQuery as CFDictionary, attrs as CFDictionary)
            if u != errSecSuccess { throw mapStatus(u) }
        default:
            throw mapStatus(status)
        }
    }
    
    public func setProtected(_ data: Data, for key: String,
                             accessControl: KCAccessControl,
                             synchronizable: Bool = false) throws {
        guard let ac = SecAccessControlCreateWithFlags(nil, accessControl.accessible, accessControl.flags, nil) else {
            throw KeychainError.unexpectedStatus(errSecParam)
        }
        var query: [String: Any] = baseQuery(for: key)
        query[kSecAttrAccessControl as String] = ac
        query[kSecAttrSynchronizable as String] = synchronizable
        query[kSecValueData as String] = data
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            // Must delete then re-add to change access control
            try delete(key)
            let again = SecItemAdd(query as CFDictionary, nil)
            if again != errSecSuccess { throw mapStatus(again) }
        } else if status != errSecSuccess {
            throw mapStatus(status)
        }
    }
    
    public func get(_ key: String,
                    context: LAContext? = nil,
                    operationPrompt: String? = nil,
                    synchronizable: Bool = false) throws -> Data {
        var q = baseQuery(for: key, matchOnly: true, synchronizable: synchronizable)
        q[kSecReturnData as String] = true
        q[kSecMatchLimit as String] = kSecMatchLimitOne
        if let ctx = context {
            if let prompt = operationPrompt {
                ctx.localizedReason = prompt
            }
            q[kSecUseAuthenticationContext as String] = ctx
        } else if let prompt = operationPrompt {
            let ctx = LAContext()
            ctx.localizedReason = prompt
            q[kSecUseAuthenticationContext as String] = ctx
        }
        var item: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &item)
        switch status {
        case errSecSuccess:
            guard let data = item as? Data else { throw KeychainError.invalidData }
            return data
        default:
            throw mapStatus(status)
        }
    }
    
    public func delete(_ key: String, synchronizable: Bool = false) throws {
        let status = SecItemDelete(baseQuery(for: key, matchOnly: true, synchronizable: synchronizable) as CFDictionary)
        switch status {
        case errSecSuccess, errSecItemNotFound: return
        default: throw mapStatus(status)
        }
    }
    
    private func baseQuery(for key: String, matchOnly: Bool = false, synchronizable: Bool = false) -> [String: Any] {
        var q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: cfg.service,
            kSecAttrAccount as String: key,
            kSecAttrSynchronizable as String: synchronizable
        ]
        if let group = cfg.accessGroup {
            q[kSecAttrAccessGroup as String] = group
        }
        if matchOnly {
            // only attributes allowed in a "match" query
            q.removeValue(forKey: kSecAttrAccessible as String)
            q.removeValue(forKey: kSecValueData as String)
        }
        return q
    }
    
    private func mapStatus(_ s: OSStatus) -> KeychainError {
        switch s {
        case errSecDuplicateItem: return .duplicate
        case errSecItemNotFound:  return .notFound
        case errSecAuthFailed:    return .authFailed
        default: return .unexpectedStatus(s)
        }
    }
}

public extension KeychainStore {
    func setString(_ string: String, for key: String,
                   accessibility: KCAccessibility = .whenUnlockedThisDeviceOnly,
                   synchronizable: Bool = false) throws {
        try set(Data(string.utf8), for: key, accessibility: accessibility, synchronizable: synchronizable)
    }
    func getString(_ key: String,
                   context: LAContext? = nil,
                   prompt: String? = nil,
                   synchronizable: Bool = false) throws -> String {
        let data = try get(key, context: context, operationPrompt: prompt, synchronizable: synchronizable)
        guard let s = String(data: data, encoding: .utf8) else { throw KeychainError.invalidData }
        return s
    }
}
