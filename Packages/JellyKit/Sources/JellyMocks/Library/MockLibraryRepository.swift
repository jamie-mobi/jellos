//
//  MockLibraryRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyData
import JellyDomain

#if DEBUG
public struct MockLibraryRepository: LibraryRepositoryProtocol {

    // MARK: - Fixtures

    public static let fixtureLibraries = [
        Library(id: "fixture-movies", name: "Movies", kind: .movies),
        Library(id: "fixture-shows", name: "Shows", kind: .shows)
    ]

    // MARK: - Input

    private let libraries: [Library]

    // MARK: - Init

    public init(libraries: [Library] = fixtureLibraries) {
        self.libraries = libraries
    }

    // MARK: - LibraryRepositoryProtocol

    public func libraries(session: Session) async throws(LibraryError) -> [Library] {
        libraries
    }
}
#endif
