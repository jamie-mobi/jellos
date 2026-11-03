//
//  MockServerStore.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyData
import JellyDomain
import Synchronization

#if DEBUG
public final class MockServerStore: ServerStoreProtocol, Sendable {

    // MARK: - Private

    private let servers: Mutex<[Server]>

    // MARK: - Init

    public init(servers: [Server] = []) {
        self.servers = Mutex(servers)
    }

    // MARK: - ServerStoreProtocol

    public func load() -> [Server] {
        servers.withLock { $0 }
    }

    public func save(_ servers: [Server]) {
        self.servers.withLock { $0 = servers }
    }
}
#endif
