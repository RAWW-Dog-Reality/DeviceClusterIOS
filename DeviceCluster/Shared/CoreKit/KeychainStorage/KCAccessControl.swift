//
//  KCAccessControl.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-08-27.
//
import Foundation

public struct KCAccessControl {
    public let accessible: CFString
    public let flags: SecAccessControlCreateFlags
    public init(accessible: CFString, flags: SecAccessControlCreateFlags) {
        self.accessible = accessible
        self.flags = flags
    }
    public static func biometryRequired() -> KCAccessControl {
        .init(accessible: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, flags: [.biometryCurrentSet])
    }
    public static func userPresence() -> KCAccessControl {
        .init(accessible: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, flags: [.userPresence])
    }
}
