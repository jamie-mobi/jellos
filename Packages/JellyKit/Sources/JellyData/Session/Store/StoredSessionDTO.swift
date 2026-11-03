//
//  StoredSessionDTO.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

struct StoredSessionDTO: Codable {

    // MARK: - Fields

    let serverID: String
    let userID: String
    let userName: String
    let hasPassword: Bool
    let imageURL: URL?

    // MARK: - Init

    init(_ session: Session) {
        serverID = session.server.id
        userID = session.user.id
        userName = session.user.name
        hasPassword = session.user.hasPassword
        imageURL = session.user.imageURL
    }
}

// MARK: - Domain mapping

extension StoredSessionDTO {
    func toDomain(server: Server, accessToken: String) -> Session {
        Session(
            server: server,
            user: User(id: userID, name: userName, hasPassword: hasPassword, imageURL: imageURL),
            accessToken: accessToken
        )
    }
}
