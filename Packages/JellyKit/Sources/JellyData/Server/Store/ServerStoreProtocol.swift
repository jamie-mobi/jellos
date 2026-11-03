//
//  ServerStoreProtocol.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain

public protocol ServerStoreProtocol: Sendable {
    func load() -> [Server]
    func save(_ servers: [Server])
}
