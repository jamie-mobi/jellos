//
//  MediaItem.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public struct MediaItem: Identifiable, Equatable, Sendable {

    // MARK: - Stored

    public let id: String
    public let name: String
    public let kind: MediaKind
    public let overview: String?
    public let genres: [String]
    public let officialRating: String?
    public let seriesID: String?
    public let seriesName: String?
    public let seasonNumber: Int?
    public let episodeNumber: Int?
    public let resumeTicks: Int
    public let isFavorite: Bool
    public let backdropURL: URL?
    public let logoURL: URL?

    // MARK: - Init

    public init(
        id: String,
        name: String,
        kind: MediaKind,
        overview: String?,
        genres: [String],
        officialRating: String?,
        seriesID: String?,
        seriesName: String?,
        seasonNumber: Int?,
        episodeNumber: Int?,
        resumeTicks: Int,
        isFavorite: Bool,
        backdropURL: URL?,
        logoURL: URL?
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.overview = overview
        self.genres = genres
        self.officialRating = officialRating
        self.seriesID = seriesID
        self.seriesName = seriesName
        self.seasonNumber = seasonNumber
        self.episodeNumber = episodeNumber
        self.resumeTicks = resumeTicks
        self.isFavorite = isFavorite
        self.backdropURL = backdropURL
        self.logoURL = logoURL
    }
}
