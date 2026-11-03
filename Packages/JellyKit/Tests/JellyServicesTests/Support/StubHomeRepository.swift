//
//  StubHomeRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyData
import JellyDomain

actor StubHomeRepository: HomeRepositoryProtocol {

    // MARK: - Configurable results

    private let nextUpResult: Result<[MediaItem], HomeError>
    private let latestResult: Result<[MediaItem], HomeError>
    private let firstEpisodeResult: Result<String?, HomeError>
    private var favoriteResult: Result<Void, HomeError>

    // MARK: - Call spies

    private(set) var favoriteCalls: [(itemID: String, isFavorite: Bool)] = []

    // MARK: - Init

    init(
        nextUp: Result<[MediaItem], HomeError> = .success([]),
        latest: Result<[MediaItem], HomeError> = .success([]),
        firstEpisode: Result<String?, HomeError> = .success(nil),
        favorite: Result<Void, HomeError> = .success(())
    ) {
        nextUpResult = nextUp
        latestResult = latest
        firstEpisodeResult = firstEpisode
        favoriteResult = favorite
    }

    // MARK: - HomeRepositoryProtocol

    func nextUp(session: Session) async throws(HomeError) -> [MediaItem] {
        try nextUpResult.get()
    }

    func latest(session: Session) async throws(HomeError) -> [MediaItem] {
        try latestResult.get()
    }

    func firstEpisodeID(seriesID: String, session: Session) async throws(HomeError) -> String? {
        try firstEpisodeResult.get()
    }

    func setFavorite(itemID: String, isFavorite: Bool, session: Session) async throws(HomeError) {
        favoriteCalls.append((itemID, isFavorite))
        try favoriteResult.get()
    }
}
