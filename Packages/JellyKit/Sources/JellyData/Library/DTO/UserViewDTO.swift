//
//  UserViewDTO.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain

struct UserViewDTO: Decodable {

    // MARK: - Fields

    let id: String?
    let name: String?
    let collectionType: String?
}

// MARK: - Domain mapping

extension UserViewDTO {
    func toDomain() -> Library? {
        guard let id, let name else {
            return nil
        }

        return Library(id: id, name: name, kind: LibraryKind(collectionType: collectionType))
    }
}
