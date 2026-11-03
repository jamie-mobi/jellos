//
//  MediaItemFixtures.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

enum MediaItemFixtures {
    static let backdrop = URL(string: "http://den.local/Items/1/Images/Backdrop/0")!

    static func movie(
        _ id: String,
        backdrop: URL? = MediaItemFixtures.backdrop,
        resumeTicks: Int = 0,
        genres: [String] = ["Action", "Sci-Fi", "Drama"]
    ) -> MediaItem {
        MediaItem(
            id: id,
            name: "Movie \(id)",
            kind: .movie,
            overview: "A movie.",
            genres: genres,
            officialRating: "PG-13",
            seriesID: nil,
            seriesName: nil,
            seasonNumber: nil,
            episodeNumber: nil,
            resumeTicks: resumeTicks,
            isFavorite: false,
            backdropURL: backdrop,
            logoURL: nil
        )
    }

    static func episode(
        _ id: String,
        seriesID: String,
        season: Int? = 2,
        episode: Int? = 3,
        resumeTicks: Int = 0,
        backdrop: URL? = MediaItemFixtures.backdrop
    ) -> MediaItem {
        MediaItem(
            id: id,
            name: "Episode \(id)",
            kind: .episode,
            overview: "An episode.",
            genres: ["Drama", "Thriller"],
            officialRating: "TV-14",
            seriesID: seriesID,
            seriesName: "Series \(seriesID)",
            seasonNumber: season,
            episodeNumber: episode,
            resumeTicks: resumeTicks,
            isFavorite: false,
            backdropURL: backdrop,
            logoURL: nil
        )
    }

    static func series(_ id: String, backdrop: URL? = MediaItemFixtures.backdrop) -> MediaItem {
        MediaItem(
            id: id,
            name: "Series \(id)",
            kind: .series,
            overview: "A series.",
            genres: ["Comedy"],
            officialRating: nil,
            seriesID: nil,
            seriesName: nil,
            seasonNumber: nil,
            episodeNumber: nil,
            resumeTicks: 0,
            isFavorite: true,
            backdropURL: backdrop,
            logoURL: nil
        )
    }
}
