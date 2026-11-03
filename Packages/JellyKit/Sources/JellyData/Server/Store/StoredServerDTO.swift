//
//  StoredServerDTO.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

struct StoredServerDTO: Codable {

    // MARK: - Fields

    let id: String
    let name: String
    let version: String
    let address: URL

    // MARK: - Init

    init(_ server: Server) {
        id = server.id
        name = server.name
        version = server.version
        address = server.address
    }
}

// MARK: - Domain mapping

extension StoredServerDTO {
    func toDomain() -> Server {
        Server(id: id, name: name, version: version, address: address)
    }
}
