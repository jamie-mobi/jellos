//
//  LibraryHTTPTransport.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

final class LibraryHTTPTransport: LibraryHTTPTransportProtocol, Sendable {

    // MARK: - Private

    private let urlSession: URLSession
    private let identity: ClientIdentity
    private let extraHeaders: [String: String]

    // MARK: - Init

    init(urlSession: URLSession, identity: ClientIdentity, extraHeaders: [String: String] = [:]) {
        self.urlSession = urlSession
        self.identity = identity
        self.extraHeaders = extraHeaders
    }

    // MARK: - LibraryHTTPTransportProtocol

    func fetchUserViews(session: Session) async throws(LibraryError) -> ItemsResponseDTO<UserViewDTO> {
        let url = APICatalogue.userViews(server: session.server.address, userID: session.user.id)
        let request = AuthorizedRequest.get(url, session: session, identity: identity, extraHeaders: extraHeaders)
        return try await HTTPSending.send(
            request,
            urlSession: urlSession,
            errorType: LibraryError.self,
            as: ItemsResponseDTO<UserViewDTO>.self
        )
    }
}
