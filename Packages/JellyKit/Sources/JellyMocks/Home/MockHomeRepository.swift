//
//  MockHomeRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyData
import JellyDomain

#if DEBUG
public struct MockHomeRepository: HomeRepositoryProtocol {

    // MARK: - Fixtures

    private static let backdrop = URL(string: "http://fixture.local:8096/Items/series-1/Images/Backdrop/0")

    public static func nextUp(withArt: Bool) -> [MediaItem] {
        [
            MediaItem(
                id: "fixture-episode",
                name: "The Harbour",
                kind: .episode,
                overview: "Storm season reaches the bay, and the ferry does not come back. "
                    + "Mara has one night to find out who cut the mooring lines before the town turns on her family.",
                genres: ["Drama", "Thriller", "Mystery"],
                officialRating: "TV-14",
                seriesID: "fixture-series",
                seriesName: "Driftwood Bay",
                seasonNumber: 2,
                episodeNumber: 3,
                resumeTicks: 0,
                isFavorite: false,
                backdropURL: withArt ? backdrop : nil,
                logoURL: nil
            )
        ]
    }

    public static func latest(withArt: Bool) -> [MediaItem] {
        [
            MediaItem(
                id: "fixture-movie",
                name: "Signal Lost",
                kind: .movie,
                overview: "A radio operator hears a voice from a ship that sank forty years ago.",
                genres: ["Sci-Fi"],
                officialRating: "PG-13",
                seriesID: nil,
                seriesName: nil,
                seasonNumber: nil,
                episodeNumber: nil,
                resumeTicks: 12_000_000_000,
                isFavorite: true,
                backdropURL: withArt ? backdrop : nil,
                logoURL: nil
            )
        ]
    }

    // MARK: - Input

    private let withArt: Bool

    // MARK: - Init

    public init(withArt: Bool = true) {
        self.withArt = withArt
    }

    // MARK: - HomeRepositoryProtocol

    public func nextUp(session: Session) async throws(HomeError) -> [MediaItem] {
        Self.nextUp(withArt: withArt)
    }

    public func latest(session: Session) async throws(HomeError) -> [MediaItem] {
        Self.latest(withArt: withArt)
    }

    public func firstEpisodeID(seriesID: String, session: Session) async throws(HomeError) -> String? {
        "fixture-episode"
    }

    public func setFavorite(itemID: String, isFavorite: Bool, session: Session) async throws(HomeError) {}
}
#endif
