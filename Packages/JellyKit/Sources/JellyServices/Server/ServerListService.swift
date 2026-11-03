//
//  ServerListService.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyData
import JellyDomain
import Observation

@MainActor
@Observable
public final class ServerListService {

    // MARK: - State

    public private(set) var servers: [Server] = []

    // MARK: - Private

    private let repository: any ServerRepositoryProtocol

    // MARK: - Init

    public init(repository: any ServerRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Intent

    public func reload() async {
        servers = await repository.savedServers()
    }
}
