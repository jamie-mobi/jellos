//
//  Server.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public struct Server: Identifiable, Equatable, Sendable {

    // MARK: - Stored

    public let id: String
    public let name: String
    public let version: String
    public let address: URL

    // MARK: - Init

    public init(id: String, name: String, version: String, address: URL) {
        self.id = id
        self.name = name
        self.version = version
        self.address = address
    }
}
