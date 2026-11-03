//
//  HomeService.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyData
import JellyDomain
import Observation

@MainActor
@Observable
public final class HomeService {

    // MARK: - State

    public enum State: Equatable, Sendable {
        case loading
        case loaded(featured: [MediaItem])
    }

    public private(set) var state: State = .loading

    // MARK: - Private

    private let repository: any HomeRepositoryProtocol

    private var favoriteOverrides: [String: Bool] = [:]

    // MARK: - Init

    public init(repository: any HomeRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Intent

    public func start(session: Session) async {
        let nextUp = await items { [repository] () async throws(HomeError) in try await repository.nextUp(session: session) }
        let latest = await items { [repository] () async throws(HomeError) in try await repository.latest(session: session) }
        guard Task.isCancelled == false else {
            return
        }

        state = .loaded(featured: FeaturedUseCase.featured(nextUp: nextUp, latest: latest))
    }

    public func isFavorite(itemID: String, default value: Bool) -> Bool {
        favoriteOverrides[itemID] ?? value
    }

    public func toggleFavorite(itemID: String, current: Bool, session: Session) async {
        favoriteOverrides[itemID] = current == false
        do {
            try await repository.setFavorite(itemID: itemID, isFavorite: current == false, session: session)
        } catch {
            favoriteOverrides[itemID] = current
        }
    }

    public func playableItemID(for hero: FeaturedHero, session: Session) async -> String? {
        if let id = hero.playItemID {
            return id
        }
        guard let seriesID = hero.seriesID else {
            return nil
        }

        do {
            return try await repository.firstEpisodeID(seriesID: seriesID, session: session)
        } catch {
            return nil
        }
    }

    // MARK: - Private

    private func items(_ load: () async throws(HomeError) -> [MediaItem]) async -> [MediaItem] {
        do {
            return try await load()
        } catch {
            return []
        }
    }
}
