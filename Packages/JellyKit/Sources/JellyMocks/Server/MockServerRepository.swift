//
//  MockServerRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyData
import JellyDomain

#if DEBUG
public struct MockServerRepository: ServerRepositoryProtocol {

    // MARK: - Types

    public enum Behaviour: Sendable {
        case answer(id: String, name: String, version: String)
        case fail(ConnectError)
    }

    // MARK: - Input

    private let behaviour: Behaviour
    private let store: any ServerStoreProtocol

    // MARK: - Init

    public init(behaviour: Behaviour, store: any ServerStoreProtocol) {
        self.behaviour = behaviour
        self.store = store
    }

    // MARK: - ServerRepositoryProtocol

    public func fetchServer(at address: URL) async throws(ConnectError) -> Server {
        switch behaviour {
        case let .answer(id, name, version):
            Server(id: id, name: name, version: version, address: address)
        case let .fail(error):
            throw error
        }
    }

    public func savedServers() async -> [Server] {
        store.load()
    }

    public func save(_ server: Server) async {
        store.save(store.load().filter { $0.id != server.id } + [server])
    }
}
#endif
