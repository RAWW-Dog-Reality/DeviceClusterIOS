//
//  Constants.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-24.
//

import Foundation

struct Constants {
    struct AppConfiguration {
        static let serviceName: String = "device-cluster"
        
    }
    
    struct Storage {
        static let secureStorageServiceName = "\(Bundle.main.bundleIdentifier ?? "com.DeviceCluster").secureStorage.v2"
        
        struct Keys {
            static let peerID = "peerID"
        }
    }
}
