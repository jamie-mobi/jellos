//
//  ServerRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

public final class ServerRepository: ServerRepositoryProtocol, Sendable {

    // MARK: - Private

    private let transport: any ServerInfoHTTPTransportProtocol
    private let store: any ServerStoreProtocol

    // MARK: - Init

    init(transport: any ServerInfoHTTPTransportProtocol, store: any ServerStoreProtocol) {
        self.transport = transport
        self.store = store
    }

    public convenience init(urlSession: URLSession, identity: ClientIdentity, store: any ServerStoreProtocol) {
        self.init(transport: ServerInfoHTTPTransport(urlSession: urlSession, identity: identity), store: store)
    }

    // MARK: - ServerRepositoryProtocol

    public func fetchServer(at address: URL) async throws(ConnectError) -> Server {
        try await transport.fetchPublicSystemInfo(server: address).toDomain(address: address)
    }

    public func savedServers() async -> [Server] {
        store.load()
    }

    public func save(_ server: Server) async {
        var servers = store.load()
        if let index = servers.firstIndex(where: { $0.id == server.id }) {
            servers[index] = server
        } else {
            servers.append(server)
        }
        store.save(servers)
    }
}
