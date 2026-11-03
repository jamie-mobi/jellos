//
//  StubLibraryRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyData
import JellyDomain

actor StubLibraryRepository: LibraryRepositoryProtocol {
    private let result: Result<[Library], LibraryError>

    init(result: Result<[Library], LibraryError>) {
        self.result = result
    }

    func libraries(session: Session) async throws(LibraryError) -> [Library] {
        try result.get()
    }
}
