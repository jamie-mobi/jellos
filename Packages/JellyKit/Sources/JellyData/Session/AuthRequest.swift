//
//  AuthRequest.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

enum AuthRequest {

    // MARK: - Requests

    static func publicUsers(server: URL, identity: ClientIdentity, extraHeaders: [String: String]) -> URLRequest {
        var request = URLRequest(url: APICatalogue.publicUsers(server: server))
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = APICatalogue.headers(identity: identity, token: nil, extra: extraHeaders)
        return request
    }

    static func authenticateByName(
        server: URL,
        body: Data,
        identity: ClientIdentity,
        extraHeaders: [String: String]
    ) -> URLRequest {
        var request = URLRequest(url: APICatalogue.authenticateByName(server: server))
        request.httpMethod = "POST"
        request.httpBody = body
        request.allHTTPHeaderFields = APICatalogue.headers(identity: identity, token: nil, extra: extraHeaders)
        return request
    }
}
