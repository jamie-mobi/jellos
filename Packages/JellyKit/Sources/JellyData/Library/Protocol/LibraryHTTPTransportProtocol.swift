//
//  LibraryHTTPTransportProtocol.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain

protocol LibraryHTTPTransportProtocol: Sendable {
    func fetchUserViews(session: Session) async throws(LibraryError) -> ItemsResponseDTO<UserViewDTO>
}
