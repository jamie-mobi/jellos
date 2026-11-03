//
//  LiveServer.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

enum LiveServer {

    // MARK: - Environment

    static var host: URL? {
        ProcessInfo.processInfo.environment["jellyfin_host"].flatMap(URL.init(string:))
    }

    static var apiKey: String? {
        ProcessInfo.processInfo.environment["jellyfin_api"]
    }

    static var isConfigured: Bool {
        host != nil && apiKey != nil
    }
}
