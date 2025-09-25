//
//  Constants.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-24.
//

import Foundation

struct Constants {
    struct AppConfiguration {
        static let serviceName = "device-cluster"
        static let peerIDPrefix = "DCPEERID-"
    }
    
    struct Storage {
        static let secureStorageServiceName = "\(Bundle.main.bundleIdentifier ?? "com.DeviceCluster").secureStorage.v5"
        
        struct Keys {
            static let peerID = "peerID"
        }
    }
}
