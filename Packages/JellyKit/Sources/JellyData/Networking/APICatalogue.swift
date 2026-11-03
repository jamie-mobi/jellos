//
//  APICatalogue.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

enum APICatalogue {

    // MARK: - Endpoints

    static func publicSystemInfo(server: URL) -> URL {
        server.appending(path: "System/Info/Public")
    }

    // MARK: - Headers

    static func headers(identity: ClientIdentity, token: String?, extra: [String: String]) -> [String: String] {
        let base = [
            "Accept": "application/json",
            "Authorization": authorization(identity: identity, token: token)
        ]

        return base.merging(extra) { _, new in new }
    }

    // MARK: - Private

    private static func authorization(identity: ClientIdentity, token: String?) -> String {
        let fields = [
            ("Client", identity.client),
            ("Device", identity.device),
            ("DeviceId", identity.deviceID),
            ("Version", identity.version)
        ] + (token.map { [("Token", $0)] } ?? [])

        return "MediaBrowser " + fields.map { "\($0.0)=\"\($0.1)\"" }.joined(separator: ", ")
    }
}
