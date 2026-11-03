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

    static func publicUsers(server: URL) -> URL {
        server.appending(path: "Users/Public")
    }

    static func authenticateByName(server: URL) -> URL {
        server.appending(path: "Users/AuthenticateByName")
    }

    static func userImage(server: URL, userID: String, tag: String) -> URL {
        server
            .appending(path: "Users/\(userID)/Images/Primary")
            .appending(queryItems: [URLQueryItem(name: "tag", value: tag), URLQueryItem(name: "maxWidth", value: "240")])
    }

    static func userViews(server: URL, userID: String) -> URL {
        server
            .appending(path: "UserViews")
            .appending(queryItems: [URLQueryItem(name: "userId", value: userID)])
    }

    static func playbackInfo(server: URL, itemID: String, userID: String) -> URL {
        server
            .appending(path: "Items/\(itemID)/PlaybackInfo")
            .appending(queryItems: [URLQueryItem(name: "userId", value: userID)])
    }

    static func directStream(server: URL, itemID: String, mediaSourceID: String, token: String) -> URL {
        server
            .appending(path: "Videos/\(itemID)/stream")
            .appending(queryItems: [
                URLQueryItem(name: "static", value: "true"),
                URLQueryItem(name: "mediaSourceId", value: mediaSourceID),
                URLQueryItem(name: "ApiKey", value: token)
            ])
    }

    // MARK: - Headers

    static func headers(identity: ClientIdentity, token: String?, extra: [String: String]) -> [String: String] {
        let base = [
            "Accept": "application/json",
            "Content-Type": "application/json",
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
