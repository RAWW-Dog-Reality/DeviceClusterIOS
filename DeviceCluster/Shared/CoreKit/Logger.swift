//
//  Logger.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-24.
//

import OSLog

struct Logger {
    private static let osLogger = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "NIPOC", category: "general")
    
    static func log(_ message: String, level: LogType = .info) {
        osLogger.log(level: level.osLogType, "\(message, privacy: .public)")
    }
    
    enum LogType {
        case info
        case debug
        case error
        case fault
        
        var osLogType: OSLogType {
            switch self {
            case .info:
                return .info
            case .debug:
                return .debug
            case .error:
                return .error
            case .fault:
                return .fault
            }
        }
    }
}
