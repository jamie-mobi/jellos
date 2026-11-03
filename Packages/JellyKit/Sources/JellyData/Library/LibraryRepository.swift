//
//  LibraryRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

public final class LibraryRepository: LibraryRepositoryProtocol, Sendable {

    // MARK: - Private

    private let transport: any LibraryHTTPTransportProtocol

    // MARK: - Init

    init(transport: any LibraryHTTPTransportProtocol) {
        self.transport = transport
    }

    public convenience init(urlSession: URLSession, identity: ClientIdentity) {
        self.init(transport: LibraryHTTPTransport(urlSession: urlSession, identity: identity))
    }

    // MARK: - LibraryRepositoryProtocol

    public func libraries(session: Session) async throws(LibraryError) -> [Library] {
        try await transport.fetchUserViews(session: session).items?.compactMap { $0.toDomain() } ?? []
    }
}
