//
//  KCAccessibility.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-08-27.
//

import Foundation

public enum KCAccessibility {
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlockThisDeviceOnly
    case raw(CFString)
    var value: CFString {
        switch self {
        case .whenUnlockedThisDeviceOnly: return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlockThisDeviceOnly: return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .raw(let v): return v
        }
    }
}
