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

    static func movie(_ id: String, backdrop: URL? = MediaItemFixtures.backdrop) -> MediaItem {
        MediaItem(
            id: id,
            name: "Movie \(id)",
            kind: .movie,
            overview: nil,
            genres: [],
            officialRating: nil,
            seriesID: nil,
            seriesName: nil,
            seasonNumber: nil,
            episodeNumber: nil,
            resumeTicks: 0,
            isFavorite: false,
            backdropURL: backdrop,
            logoURL: nil
        )
    }

    static func series(_ id: String) -> MediaItem {
        MediaItem(
            id: id,
            name: "Series \(id)",
            kind: .series,
            overview: nil,
            genres: [],
            officialRating: nil,
            seriesID: nil,
            seriesName: nil,
            seasonNumber: nil,
            episodeNumber: nil,
            resumeTicks: 0,
            isFavorite: false,
            backdropURL: backdrop,
            logoURL: nil
        )
    }
}
