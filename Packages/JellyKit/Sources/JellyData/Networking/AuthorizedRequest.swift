//
//  AuthorizedRequest.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

enum AuthorizedRequest {
    static func get(
        _ url: URL,
        session: Session,
        identity: ClientIdentity,
        extraHeaders: [String: String]
    ) -> URLRequest {
        make(url, method: "GET", session: session, identity: identity, extraHeaders: extraHeaders)
    }

    static func make(
        _ url: URL,
        method: String,
        session: Session,
        identity: ClientIdentity,
        extraHeaders: [String: String],
        body: Data? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.allHTTPHeaderFields = APICatalogue.headers(
            identity: identity,
            token: session.accessToken,
            extra: extraHeaders
        )
        return request
    }
}
