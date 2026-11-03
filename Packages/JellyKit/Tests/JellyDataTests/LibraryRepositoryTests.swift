//
//  LibraryRepositoryTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import JellyData
import JellyDomain
import Testing

@Suite("LibraryRepository", .tags(.data))
struct LibraryRepositoryTests {
    private struct StubTransport: LibraryHTTPTransportProtocol {
        func fetchUserViews(session: Session) async throws(LibraryError) -> ItemsResponseDTO<UserViewDTO> {
            try APIResponseHandling.decode(
                ItemsResponseDTO<UserViewDTO>.self,
                from: Data(LibraryPayloadFixtures.userViews.utf8),
                as: LibraryError.self
            )
        }
    }

    @Test
    func `libraries keep server order, map the kind, and drop entries with no id`() async throws {
        let session = try Session(
            server: Server(id: "s", name: "Den", version: "1", address: #require(URL(string: "http://den.local"))),
            user: User(id: "u", name: "Alice", hasPassword: true, imageURL: nil),
            accessToken: "t"
        )

        let libraries = try await LibraryRepository(transport: StubTransport()).libraries(session: session)

        #expect(libraries == [
            Library(id: "lib-movies", name: "Movies", kind: .movies),
            Library(id: "lib-shows", name: "Shows", kind: .shows)
        ])
    }
}
