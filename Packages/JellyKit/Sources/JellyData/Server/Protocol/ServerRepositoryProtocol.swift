//
//  ServerRepositoryProtocol.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

public protocol ServerRepositoryProtocol: Sendable {
    func fetchServer(at address: URL) async throws(ConnectError) -> Server
    func savedServers() async -> [Server]
    func save(_ server: Server) async
}
