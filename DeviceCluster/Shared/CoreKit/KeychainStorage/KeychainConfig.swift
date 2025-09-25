//
//  KeychainConfig.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-08-27.
//

public struct KeychainConfig {
    public let service: String
    public let accessGroup: String?
    public init(service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }
}
