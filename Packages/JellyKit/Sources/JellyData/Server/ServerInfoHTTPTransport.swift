//
//  ServerInfoHTTPTransport.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

final class ServerInfoHTTPTransport: ServerInfoHTTPTransportProtocol, Sendable {

    // MARK: - Private

    private let urlSession: URLSession
    private let identity: ClientIdentity
    private let extraHeaders: [String: String]

    // MARK: - Init

    init(urlSession: URLSession, identity: ClientIdentity, extraHeaders: [String: String] = [:]) {
        self.urlSession = urlSession
        self.identity = identity
        self.extraHeaders = extraHeaders
    }

    // MARK: - ServerInfoHTTPTransportProtocol

    func fetchPublicSystemInfo(server: URL) async throws(ConnectError) -> PublicSystemInfoDTO {
        let request = ServerInfoRequest.publicSystemInfo(server: server, identity: identity, extraHeaders: extraHeaders)
        return try await HTTPSending.send(
            request,
            urlSession: urlSession,
            errorType: ConnectError.self,
            as: PublicSystemInfoDTO.self
        )
    }
}
