//
//  ServerInfoRequest.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

enum ServerInfoRequest {

    // MARK: - Requests

    static func publicSystemInfo(
        server: URL,
        identity: ClientIdentity,
        extraHeaders: [String: String]
    ) -> URLRequest {
        var request = URLRequest(url: APICatalogue.publicSystemInfo(server: server))
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = APICatalogue.headers(identity: identity, token: nil, extra: extraHeaders)
        return request
    }
}
