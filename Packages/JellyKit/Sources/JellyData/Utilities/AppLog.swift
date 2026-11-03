//
//  AppLog.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OSLog

enum AppLog {

    // MARK: - Private

    private static let logger = Logger(subsystem: "mobi.jamie.jellyOS", category: "app")

    // MARK: - Levels

    static func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }

    static func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }
}
