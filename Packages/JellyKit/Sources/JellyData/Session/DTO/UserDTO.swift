//
//  UserDTO.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

struct UserDTO: Codable {

    // MARK: - Fields

    let id: String?
    let name: String?
    let hasPassword: Bool?
    let primaryImageTag: String?
}

// MARK: - Domain mapping

extension UserDTO {
    func toDomain(server: URL) throws(SignInError) -> User {
        guard let id, let name else {
            throw .missingSession
        }

        return User(
            id: id,
            name: name,
            hasPassword: hasPassword ?? true,
            imageURL: primaryImageTag.map { APICatalogue.userImage(server: server, userID: id, tag: $0) }
        )
    }
}
