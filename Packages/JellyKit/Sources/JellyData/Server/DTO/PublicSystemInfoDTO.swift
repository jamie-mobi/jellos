//
//  PublicSystemInfoDTO.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

struct PublicSystemInfoDTO: Decodable {

    // MARK: - Fields

    let serverName: String?
    let version: String?
    let id: String?
}

// MARK: - Domain mapping

extension PublicSystemInfoDTO {
    func toDomain(address: URL) throws(ConnectError) -> Server {
        guard let serverName, let id else {
            throw .missingServerInfo
        }

        return Server(id: id, name: serverName, version: version ?? "", address: address)
    }
}
