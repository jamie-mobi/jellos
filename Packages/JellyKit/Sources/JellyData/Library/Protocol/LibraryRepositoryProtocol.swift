//
//  LibraryRepositoryProtocol.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain

public protocol LibraryRepositoryProtocol: Sendable {
    func libraries(session: Session) async throws(LibraryError) -> [Library]
}
